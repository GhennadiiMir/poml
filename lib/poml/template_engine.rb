module Poml
  # Template engine for handling {{variable}} substitutions and control structures
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

    def evaluate_attribute_expression(expression)
      # Handle attribute expressions that might return non-string values
      if expression =~ /^(\w+(?:\.\w+)*)\s*\+\s*(\d+)$/
        variable_path = $1
        increment = $2.to_i
        
        value = get_nested_variable(variable_path)
        if value.is_a?(Numeric)
          value + increment
        else
          expression
        end
      elsif expression =~ /^(\w+(?:\.\w+)*)$/
        # Simple variable or dot notation lookup
        variable_path = $1
        get_nested_variable(variable_path)
      elsif expression =~ /^(true|false)$/i
        $1.downcase == 'true'
      elsif expression =~ /^-?\d+$/
        $1.to_i
      elsif expression =~ /^-?\d*\.\d+$/
        $1.to_f
      elsif @context.variables.key?(expression)
        # Direct variable lookup (backward compatibility)
        @context.variables[expression]
      else
        # Try to evaluate as a more complex expression
        evaluate_complex_expression(expression)
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
        # Try to evaluate as a more complex expression
        result = evaluate_complex_expression(expression)
        result ? result.to_s : "{{#{expression}}}"
      end
    end
    
    def evaluate_complex_expression(expression)
      # Handle more complex expressions like array literals, object access, etc.
      
      # Array literals like ['apple', 'banana', 'cherry']
      if expression =~ /^\[(.+)\]$/
        array_content = $1
        # Simple parsing for string arrays
        if array_content.match(/^'[^']*'(?:\s*,\s*'[^']*')*$/)
          return array_content.split(',').map { |item| item.strip.gsub(/^'|'$/, '') }
        end
      end
      
      # Object literals like { name: 'John', age: 30 }
      if expression =~ /^\{(.+)\}$/
        # This would need a proper expression parser for full support
        # For now, return the expression as-is
        return expression
      end
      
      # Ternary operator like condition ? valueIfTrue : valueIfFalse
      if expression =~ /^(.+)\s*\?\s*(.+)\s*:\s*(.+)$/
        condition = $1.strip
        true_value = $2.strip
        false_value = $3.strip
        
        condition_result = evaluate_condition(condition)
        if condition_result
          evaluate_expression(true_value)
        else
          evaluate_expression(false_value)
        end
      end
      
      nil
    end
    
    def evaluate_condition(condition)
      # Simple condition evaluation
      case condition
      when 'true'
        true
      when 'false'
        false
      when /^!(.+)$/
        !evaluate_condition($1.strip)
      else
        value = get_nested_variable(condition)
        !!value
      end
    end
    
    def get_nested_variable(path)
      # Handle dot notation like "loop.index"
      parts = path.split('.')
      
      # Handle both Context objects and raw variable hashes
      value = if @context.respond_to?(:variables)
        @context.variables
      else
        @context
      end
      
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
