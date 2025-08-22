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
        # Return the parsed schema directly - don't wrap it
        parsed
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
          # Return the parsed schema directly - don't wrap it
          parsed
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
  end
end
