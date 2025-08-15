module Poml
  # Template engine for handling {{variable}} substitutions
  class TemplateEngine
    def initialize(context)
      @context = context
    end

    def substitute(text)
      return text unless text.is_a?(String)
      
      # Handle {{variable}} substitutions
      text.gsub(/\{\{(.+?)\}\}/) do |match|
        expression = $1.strip
        evaluate_expression(expression)
      end
    end

    private

    def evaluate_expression(expression)
      # Handle dot notation and arithmetic expressions
      
      # Simple arithmetic operations like loop.index+1
      if expression =~ /^(\w+(?:\.\w+)*)\s*\+\s*(\d+)$/
        variable_path = $1
        increment = $2.to_i
        
        value = get_nested_variable(variable_path)
        if value.is_a?(Numeric)
          (value + increment).to_s
        else
          "{{#{expression}}}"
        end
      elsif expression =~ /^(\w+(?:\.\w+)*)$/
        # Simple variable or dot notation lookup
        variable_path = $1
        value = get_nested_variable(variable_path)
        value ? value.to_s : "{{#{expression}}}"
      elsif @context.variables.key?(expression)
        # Direct variable lookup (backward compatibility)
        @context.variables[expression].to_s
      else
        # Return original expression if not found
        "{{#{expression}}}"
      end
    end
    
    def get_nested_variable(path)
      # Handle dot notation like "loop.index"
      parts = path.split('.')
      value = @context.variables
      
      parts.each do |part|
        if value.is_a?(Hash) && value.key?(part)
          value = value[part]
        elsif value.is_a?(Hash) && value.key?(part.to_sym)
          value = value[part.to_sym]
        else
          return nil
        end
      end
      
      value
    end
  end
end
