module Poml
  # ToolDefinition component for registering AI tools
  class ToolDefinitionComponent < Component
    def render
      apply_stylesheet
      
      name = get_attribute('name')
      description = get_attribute('description')
      
      return '' unless name  # Name is required for tools
      
      # Check if this is declarative XML format (has description/parameter children)
      has_xml_children = @element.children.any? { |child| ['description', 'parameter'].include?(child.tag_name.to_s) }
      
      if has_xml_children
        # Handle declarative XML format
        handle_declarative_format(name, description)
      else
        # Handle JSON format (original behavior)
        handle_json_format(name, description)
      end
      
      # Meta-like components don't produce output
      ''
    end
    
    private
    
    def handle_declarative_format(name, description)
      tool_def = {
        'name' => name,
        'description' => extract_description(description)
      }
      
      # Extract tool-level metadata
      extract_tool_metadata(tool_def)
      
      # Extract parameters
      tool_def['parameters'] = extract_parameters
      
      # Extract tool-level examples
      extract_tool_examples(tool_def)
      
      # Register the tool
      @context.tools ||= []
      @context.tools << tool_def
    end
    
    def extract_tool_metadata(tool_def)
      # Extract version, category, requires_auth, etc.
      %w[version category requires_auth deprecated].each do |attr|
        element = @element.children.find { |child| child.tag_name.to_s == attr }
        if element
          content = element.content&.strip
          if attr == 'requires_auth' || attr == 'deprecated'
            # Convert to boolean
            tool_def[attr] = content == 'true'
          else
            tool_def[attr] = content
          end
        end
      end
    end
    
    def extract_tool_examples(tool_def)
      example_elements = @element.children.select { |child| child.tag_name.to_s == 'example' }
      return if example_elements.empty?
      
      if example_elements.length == 1
        # Single example
        tool_def['example'] = parse_example_element(example_elements.first)
      else
        # Multiple examples
        tool_def['examples'] = example_elements.map { |elem| parse_example_element(elem) }
      end
    end
    
    def parse_example_element(example_element)
      example = {}
      
      # Check for title and description
      title_elem = example_element.children.find { |child| child.tag_name.to_s == 'title' }
      description_elem = example_element.children.find { |child| child.tag_name.to_s == 'description' }
      parameters_elem = example_element.children.find { |child| child.tag_name.to_s == 'parameters' }
      
      example['title'] = title_elem.content&.strip if title_elem
      example['description'] = description_elem.content&.strip if description_elem
      
      if parameters_elem
        # Parse JSON parameters
        content = parameters_elem.content.strip
        begin
          # Clean up the JSON content - remove extra whitespace and normalize
          cleaned_content = content.gsub(/\n\s*/, ' ').gsub(/\s+/, ' ')
          example['parameters'] = JSON.parse(cleaned_content)
        rescue JSON::ParserError => e
          # If JSON parsing fails, try to clean it up more aggressively
          begin
            # Replace problematic characters and try again
            fixed_content = content.gsub(/\n/, '\\n').gsub(/\r/, '\\r').gsub(/\t/, '\\t')
            example['parameters'] = JSON.parse(fixed_content)
          rescue JSON::ParserError
            # If still failing, store as string
            example['parameters'] = content
          end
        end
      end
      
      example
    end
    
    def handle_json_format(name, description)
      # Support both old 'lang' and new 'parser' attributes for compatibility
      parser_attr = get_attribute('parser') || get_attribute('lang', 'auto')
      
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
        
        # Extract description from JSON if not provided as attribute
        json_description = nil
        if schema.is_a?(Hash) && schema['description']
          json_description = schema['description']
        end
        
        # Use attribute description first, then JSON description, then nil
        final_description = description || json_description
        
        # Store tool with string keys for JSON compatibility
        tool_def = {
          'name' => name,
          'description' => final_description,
          'schema' => schema.is_a?(String) ? schema : JSON.generate(schema)
        }
        
        # For compatibility with expected structure, also store as parameters
        if schema.is_a?(Hash)
          # Remove description from parameters if it was moved to top level
          params = schema.dup
          params.delete('description')
          
          # If the schema has a 'parameters' key, extract it
          if params['parameters']
            tool_def['parameters'] = params['parameters']
          else
            tool_def['parameters'] = params
          end
        end
        
        @context.tools << tool_def
      end
    end
    
    def extract_description(fallback_description = nil)
      description_element = @element.children.find { |child| child.tag_name.to_s == 'description' }
      return description_element&.content&.strip if description_element
      
      # Fallback to attribute description
      fallback_description || ''
    end
    
    def extract_parameters
      parameter_elements = @element.children.select { |child| child.tag_name.to_s == 'parameter' }
      
      if parameter_elements.empty?
        # If no parameter elements, return empty object
        return {}
      end
      
      parameters = {}
      
      parameter_elements.each do |param_element|
        param_name = param_element.attributes['name']
        next unless param_name
        
        param_type = param_element.attributes['type'] || 'string'
        param_required = param_element.attributes['required']
        param_description = extract_parameter_description(param_element)
        
        param_def = {
          'type' => param_type,
          'required' => param_required == 'true' || param_required == true
        }
        
        param_def['description'] = param_description if param_description && !param_description.empty?
        
        # Handle enum values
        enum_element = param_element.children.find { |child| child.tag_name.to_s == 'enum' }
        if enum_element
          values = enum_element.children.select { |child| child.tag_name.to_s == 'value' }
                                       .map(&:content)
                                       .compact
          param_def['enum'] = values unless values.empty?
        end
        
        # Handle array items
        items_element = param_element.children.find { |child| child.tag_name.to_s == 'items' }
        if items_element && param_type == 'array'
          items_type = items_element.attributes['type'] || 'string'
          items_description = extract_parameter_description(items_element)
          
          items_def = { 'type' => items_type }
          items_def['description'] = items_description if items_description && !items_description.empty?
          
          # Handle example in items
          items_example_elem = items_element.children.find { |child| child.tag_name.to_s == 'example' }
          if items_example_elem
            items_def['example'] = items_example_elem.content&.strip
          end
          
          param_def['items'] = items_def
        end
        
        # Handle parameter examples
        example_element = param_element.children.find { |child| child.tag_name.to_s == 'example' }
        if example_element
          param_def['example'] = example_element.content&.strip
        end
        
        # Handle object properties
        properties_element = param_element.children.find { |child| child.tag_name.to_s == 'properties' }
        if properties_element && param_type == 'object'
          properties = {}
          
          property_elements = properties_element.children.select { |child| child.tag_name.to_s == 'property' }
          property_elements.each do |prop_element|
            prop_name = prop_element.attributes['name']
            next unless prop_name
            
            prop_type = prop_element.attributes['type'] || 'string'
            prop_description = extract_parameter_description(prop_element)
            
            prop_def = { 'type' => prop_type }
            prop_def['description'] = prop_description if prop_description && !prop_description.empty?
            
            properties[prop_name] = prop_def
          end
          
          param_def['properties'] = properties unless properties.empty?
        end
        
        # Handle schema references (raw JSON schema)
        schema_element = param_element.children.find { |child| child.tag_name.to_s == 'schema' }
        if schema_element
          schema_content = schema_element.content.strip
          begin
            # Try to parse as JSON to validate
            parsed_schema = JSON.parse(schema_content)
            param_def['schema'] = parsed_schema
          rescue JSON::ParserError
            # If invalid JSON, store as string
            param_def['schema'] = schema_content
          end
        end
        
        parameters[param_name] = param_def
      end
      
      parameters
    end
    
    def extract_parameter_description(element)
      # Check for description child element first
      description_child = element.children.find { |child| child.tag_name.to_s == 'description' }
      return description_child.content&.strip if description_child
      
      # Fallback to element content if no description child
      element.content&.strip
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
