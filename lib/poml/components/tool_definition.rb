module Poml
  # ToolDefinition component for registering AI tools
  class ToolDefinitionComponent < Component
    def render
      apply_stylesheet
      
      name = get_attribute('name')
      description = get_attribute('description')
      # Support both old 'lang' and new 'parser' attributes for compatibility
      parser_attr = get_attribute('parser') || get_attribute('lang', 'auto')
      
      return '' unless name  # Name is required for tools
      
      content = @element.content.strip
      
      # Auto-detect format if parser_attr is auto
      if parser_attr == 'auto'
        parser_attr = content.start_with?('{') ? 'json' : 'eval'
      end
      
      # Handle new 'eval' parser type as alias for 'expr'
      parser_attr = 'expr' if parser_attr == 'eval'
      
      schema = case parser_attr.downcase
      when 'json'
        parse_json_schema(content)
      when 'expr'
        evaluate_expression_schema(content)
      else
        nil
      end
      
      if schema
        @context.tools ||= []
        # Store tool with string keys for JSON compatibility
        tool_def = {
          'name' => name,
          'description' => description,
          'schema' => schema.is_a?(String) ? schema : JSON.generate(schema)
        }
        
        # For compatibility with expected structure, also store as parameters
        if schema.is_a?(Hash)
          tool_def['parameters'] = schema
        end
        
        @context.tools << tool_def
      end
      
      # Meta-like components don't produce output
      ''
    end
    
    private
    
    def parse_json_schema(content)
      # Apply template substitution first
      substituted_content = @context.template_engine.substitute(content)
      
      begin
        parsed = JSON.parse(substituted_content)
        # Apply enhanced tool registration features
        enhanced_schema = apply_tool_enhancements(parsed)
        enhanced_schema
      rescue JSON::ParserError => e
        raise Poml::Error, "Invalid JSON schema for tool '#{get_attribute('name')}': #{e.message}"
      end
    end
    
    def evaluate_expression_schema(content)
      # Apply template substitution first
      substituted_content = @context.template_engine.substitute(content)
      
      begin
        # In a real implementation, this would evaluate JavaScript expressions
        # For now, we'll try to parse as JSON if it looks like JSON, 
        # otherwise treat it as a placeholder
        if substituted_content.strip.start_with?('{', '[')
          parsed = JSON.parse(substituted_content)
          # Apply enhanced tool registration features
          enhanced_schema = apply_tool_enhancements(parsed)
          enhanced_schema
        else
          # This would need a JavaScript engine in a real implementation
          # For now, return a placeholder that indicates expression evaluation
          {
            "_expression" => substituted_content,
            "_note" => "Expression evaluation not implemented in Ruby gem"
          }
        end
      rescue JSON::ParserError
        # Return expression as-is if it can't be parsed as JSON
        {
          "_expression" => substituted_content,
          "_note" => "Expression evaluation not implemented in Ruby gem"
        }
      end
    end
    
    # Apply enhanced tool registration features
    def apply_tool_enhancements(schema)
      return schema unless schema.is_a?(Hash)
      
      # Apply parameter key conversion and runtime type conversion
      enhanced_schema = convert_parameter_keys(schema)
      enhanced_schema = apply_runtime_parameter_conversion(enhanced_schema)
      enhanced_schema
    end
    
    # Convert kebab-case keys to camelCase recursively
    def convert_parameter_keys(obj)
      case obj
      when Hash
        converted = {}
        obj.each do |key, value|
          # Convert kebab-case to camelCase
          new_key = kebab_to_camel_case(key.to_s)
          
          # Special handling for 'required' array
          if key == 'required' && value.is_a?(Array)
            converted[new_key] = value.map { |req_key| kebab_to_camel_case(req_key.to_s) }
          else
            converted[new_key] = convert_parameter_keys(value)
          end
        end
        converted
      when Array
        obj.map { |item| convert_parameter_keys(item) }
      else
        obj
      end
    end
    
    # Convert kebab-case string to camelCase
    def kebab_to_camel_case(str)
      # Split on hyphens and convert to camelCase
      parts = str.split('-')
      return str if parts.length == 1  # No conversion needed
      
      parts[0] + parts[1..-1].map(&:capitalize).join
    end
    
    # Apply runtime parameter type conversion
    def apply_runtime_parameter_conversion(schema)
      return schema unless schema.is_a?(Hash)
      
      converted = schema.dup
      
      # Process properties if they exist
      if converted['properties'].is_a?(Hash)
        converted['properties'] = converted['properties'].map do |key, prop|
          [key, convert_property_value(prop)]
        end.to_h
      end
      
      converted
    end
    
    # Convert individual property values based on 'convert' attribute
    def convert_property_value(property)
      return property unless property.is_a?(Hash) && property['convert']
      
      converted_prop = property.dup
      convert_value = property['convert']
      prop_type = property['type']
      
      begin
        case prop_type
        when 'boolean'
          # Convert various truthy/falsy values to boolean
          case convert_value.to_s.downcase
          when 'true', '1', 'yes', 'on'
            # Keep the convert attribute for now but could be removed
          when 'false', '0', 'no', 'off'
            # Keep the convert attribute for now but could be removed
          end
        when 'number'
          # Validate that the value can be converted to a number
          Float(convert_value) # This will raise an exception if invalid
        when 'object', 'array'
          # Validate that the value is valid JSON
          JSON.parse(convert_value) # This will raise an exception if invalid
        end
      rescue StandardError
        # If conversion fails, remove the convert attribute silently
        converted_prop.delete('convert')
      end
      
      converted_prop
    end
  end
end
