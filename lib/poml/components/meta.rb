module Poml
  # Meta component for document metadata and configuration
  class MetaComponent < Component
    def render
      apply_stylesheet
      
      type = get_attribute('type')
      
      if type
        handle_typed_meta(type)
      else
        handle_general_meta
      end
      
      # If meta has children and variables are set, render children with variable substitution
      if @element.children.any? && get_attribute('variables')
        child_content = @element.children.map do |child|
          # Render the child element
          rendered_child = Components.render_element(child, @context)
          # Apply template substitution to the rendered content
          @context.template_engine.substitute(rendered_child)
        end.join('')
        return child_content
      end
      
      # Meta components don't produce output by default
      ''
    end
    
    private
    
    def handle_typed_meta(type)
      case type.downcase
      when 'responseschema', 'response_schema'
        handle_response_schema
      when 'tool', 'tool-definition', 'tooldefinition'
        handle_tool_registration
      when 'runtime'
        handle_runtime_parameters
      else
        # Unknown meta type, ignore
      end
    end
    
    def handle_general_meta
      # Handle template variables
      variables_attr = get_attribute('variables')
      if variables_attr
        handle_variables(variables_attr)
      end
      
      # Handle tool registration via tool attribute
      tool_attr = get_attribute('tool')
      if tool_attr
        handle_tool_registration_with_name(tool_attr)
      end
      
      # Handle general metadata attributes
      %w[title description author keywords].each do |attr|
        value = get_attribute(attr)
        if value
          @context.custom_metadata[attr] = value
        end
      end
      
      # Handle version control
      min_version = get_attribute('minVersion')
      max_version = get_attribute('maxVersion')
      
      if min_version
        check_version_compatibility(min_version, 'minimum')
      end
      
      if max_version
        check_version_compatibility(max_version, 'maximum')
      end
      
      # Handle component control
      components = get_attribute('components')
      if components
        apply_component_control(components)
      end
    end
    
    def handle_response_schema
      # Support both old 'lang' and new 'parser' attributes for compatibility
      parser_attr = get_attribute('parser') || get_attribute('lang', 'auto')
      _name = get_attribute('name')  # May be used for schema naming in future
      _description = get_attribute('description')  # May be used for schema documentation in future
      
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
        # Check if there's already a response schema defined
        if @context.response_schema
          raise Poml::Error, "Multiple response schemas are not allowed. Only one response schema per document is supported."
        end
        
        # Store the schema directly for simplicity
        @context.response_schema = schema
      end
    end
    
    def handle_tool_registration
      name = get_attribute('name')
      description = get_attribute('description')
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
      
      # Apply enhanced tool registration features
      if schema
        schema = apply_tool_enhancements(schema)
      end
      
      if schema
        @context.tools ||= []
        
        # If name and description are provided as attributes, use them
        if name
          tool_def = {
            'name' => name,
            'description' => description,
            'schema' => schema.is_a?(String) ? schema : JSON.generate(schema)
          }
          
          # Merge in the parsed schema for backward compatibility
          if schema.is_a?(Hash)
            tool_def.merge!(schema)
          end
        elsif schema.is_a?(Hash) && schema['name']
          # If the schema contains the full tool definition, use it directly
          tool_def = schema
        else
          # No valid tool definition found
          return
        end
        
        @context.tools << tool_def
      end
    end
    
    def handle_tool_registration_with_name(tool_name)
      description = get_attribute('description')
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
      
      # Apply enhanced tool registration features
      if schema
        schema = apply_tool_enhancements(schema)
      end
      
      if schema
        @context.tools ||= []
        # Store tool with string keys for JSON compatibility
        tool_def = {
          'name' => tool_name,
          'description' => description
        }
        # Merge in the parsed schema (should include parameters, etc.)
        tool_def.merge!(schema) if schema.is_a?(Hash)
        
        @context.tools << tool_def
      end
    end
    
    def handle_runtime_parameters
      # Collect all attributes except 'type' as runtime parameters
      runtime_params = {}
      
      @element.attributes.each do |key, value|
        next if key == 'type'
        
        # Convert common parameter types
        runtime_params[key] = case key.downcase
        when 'temperature', 'topp', 'frequencypenalty', 'presencepenalty'
          value.to_f
        when 'maxoutputtokens', 'seed'
          value.to_i
        else
          value
        end
      end
      
      @context.runtime_parameters ||= {}
      @context.runtime_parameters.merge!(runtime_params)
    end
    
    def parse_json_schema(content)
      # Handle template expressions in JSON
      processed_content = @context.template_engine.substitute(content)
      
      begin
        JSON.parse(processed_content)
      rescue JSON::ParserError
        nil
      end
    end
    
    def evaluate_expression_schema(content)
      # Handle template expressions in the content
      processed_content = @context.template_engine.substitute(content)
      
      begin
        # For expression schemas, try to parse as JSON first
        # In the original POML, 'expr' mode evaluates JavaScript expressions
        # but for simplicity in Ruby, we'll try JSON parsing
        JSON.parse(processed_content)
      rescue JSON::ParserError
        # If JSON parsing fails, return a simple schema object
        # This is a fallback for complex expressions that can't be easily evaluated
        { 'type' => 'string', 'description' => 'Expression schema result' }
      end
    end
    
    def check_version_compatibility(version, type)
      current_version = Poml::VERSION
      
      if type == 'minimum' && compare_versions(current_version, version) < 0
        raise "POML version #{version} or higher required, but current version is #{current_version}"
      elsif type == 'maximum' && compare_versions(current_version, version) > 0
        # Just warn for maximum version
        puts "Warning: POML version #{current_version} may not be compatible with documents requiring version #{version} or lower"
      end
    end
    
    def compare_versions(v1, v2)
      # Simple semantic version comparison
      v1_parts = v1.split('.').map(&:to_i)
      v2_parts = v2.split('.').map(&:to_i)
      
      [v1_parts.length, v2_parts.length].max.times do |i|
        a = v1_parts[i] || 0
        b = v2_parts[i] || 0
        
        return a <=> b if a != b
      end
      
      0
    end
    
    def handle_variables(variables_attr)
      # Parse variables JSON and add to context
      begin
        variables = JSON.parse(variables_attr)
        if variables.is_a?(Hash)
          # Merge variables into context
          variables.each do |key, value|
            @context.variables[key] = value
          end
        end
      rescue JSON::ParserError => e
        # Invalid JSON, ignore silently or log error
        puts "Warning: Invalid JSON in meta variables: #{e.message}" if ENV['POML_DEBUG']
      end
    end
    
    def apply_component_control(components_attr)
      # Parse component control string like "-table,-image" or "+table"
      components_attr.split(',').each do |component_spec|
        component_spec = component_spec.strip
        
        if component_spec.start_with?('+')
          # Re-enable component
          component_name = component_spec[1..-1]
          @context.disabled_components&.delete(component_name)
        elsif component_spec.start_with?('-')
          # Disable component
          component_name = component_spec[1..-1]
          @context.disabled_components ||= Set.new
          @context.disabled_components.add(component_name)
        end
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
