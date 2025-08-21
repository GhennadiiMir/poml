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
      when 'tool'
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
      lang = get_attribute('lang', 'auto')
      _name = get_attribute('name')  # May be used for schema naming in future
      _description = get_attribute('description')  # May be used for schema documentation in future
      
      content = @element.content.strip
      
      # Auto-detect format if lang is auto
      if lang == 'auto'
        lang = content.start_with?('{') ? 'json' : 'expr'
      end
      
      schema = case lang.downcase
      when 'json'
        parse_json_schema(content)
      when 'expr'
        evaluate_expression_schema(content)
      else
        nil
      end
      
      if schema
        # Store the schema directly for simplicity
        @context.response_schema = schema
      end
    end
    
    def handle_tool_registration
      name = get_attribute('name')
      description = get_attribute('description')
      lang = get_attribute('lang', 'auto')
      
      return unless name
      
      content = @element.content.strip
      
      # Auto-detect format if lang is auto
      if lang == 'auto'
        lang = content.start_with?('{') ? 'json' : 'expr'
      end
      
      schema = case lang.downcase
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
      # This is a simplified version - in a full implementation,
      # you'd want to evaluate JavaScript expressions with Zod support
      begin
        # For now, just return the content as-is for expression schemas
        # In a complete implementation, you'd evaluate this as JavaScript
        { type: 'expression', content: content }
      rescue
        nil
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
  end
end
