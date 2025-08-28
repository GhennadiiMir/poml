module Poml
  # OutputSchema component for defining AI response schemas
  class OutputSchemaComponent < Component
    def render
      apply_stylesheet
      
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
          raise Poml::Error, "Multiple output-schema elements are not allowed. Only one response schema per document is supported."
        end

        # Store the schema with metadata structure expected by tests
        schema_with_metadata = {
          'schema' => schema
        }
        
        # Add name if provided
        if _name
          schema_with_metadata['name'] = _name
        end
        
        # Add description if provided
        if _description
          schema_with_metadata['description'] = _description
        end
        
        # Store the schema directly for simplicity (this is what the renderer uses for response_schema)
        @context.response_schema = schema
        
        # Also store the structured version for the schemas array
        @context.response_schema_with_metadata = schema_with_metadata
      end
      
      # Meta-like components don't produce output
      ''
    end
    
    private
    
    def parse_json_schema(content)
      # Apply template substitution first
      substituted_content = @context.template_engine.substitute(content)
      
      begin
        JSON.parse(substituted_content)
      rescue JSON::ParserError => e
        raise Poml::Error, "Invalid JSON schema: #{e.message}"
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
          JSON.parse(substituted_content)
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
