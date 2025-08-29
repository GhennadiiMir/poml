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

    def safe_substitute(text)
      return text unless text.is_a?(String)
      
      # Handle {{variable}} substitutions, but only substitute simple string values
      # to avoid XML parsing issues with complex values in attributes
      text.gsub(/\{\{(.+?)\}\}/) do |match|
        expression = $1.strip
        
        # Don't substitute complex expressions (comparisons, ternary operators, etc.)
        # These should be handled during rendering when variables are in proper scope
        if expression.include?('==') || expression.include?('!=') || 
           expression.include?('>=') || expression.include?('<=') || 
           expression.include?('>') || expression.include?('<') ||
           expression.include?('?') || expression.include?(':')
          match # Keep {{...}} for complex expressions
        else
          # Check what type of value this expression would resolve to
          # without actually evaluating it to string first
          raw_value = evaluate_attribute_expression(expression)
          
          # Only substitute if:
          # 1. The value exists (not nil)
          # 2. The value is a simple type (string, number, boolean)
          # Leave nil values and complex objects as template variables for component-level handling
          case raw_value
          when String, Numeric, TrueClass, FalseClass
            raw_value.to_s
          when NilClass
            match # Keep {{...}} for nil values - they might be valid in child contexts
          else
            match # Return original {{...}} for complex values like arrays/hashes
          end
        end
      end
    end

    def evaluate_attribute_expression(expression)
      # Handle attribute expressions that might return non-string values
      
      # Handle string literals with quotes
      if expression =~ /^"([^"]*)"$/ || expression =~ /^'([^']*)'$/
        return $1  # Return the content without quotes
      end
      
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
      
      # Handle string literals with quotes
      if expression =~ /^"([^"]*)"$/ || expression =~ /^'([^']*)'$/
        return $1  # Return the content without quotes
      end
      
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
      
      # Handle logical OR operator (||) - return first truthy value
      if expression =~ /^(.+?)\s*\|\|\s*(.+)$/
        left_expression = $1.strip
        right_expression = $2.strip
        
        left_value = evaluate_expression(left_expression)
        
        # Return left value if it's truthy (not nil, false, or empty string)
        if left_value && left_value != "" && left_value != false
          return left_value
        else
          # Evaluate and return the right expression
          return evaluate_expression(right_expression)
        end
      end
      
      # Try to parse as JSON first (for arrays and objects)
      begin
        require 'json'
        return JSON.parse(expression)
      rescue JSON::ParserError
        # Not valid JSON, continue with other parsing
      end
      
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
          return evaluate_expression(true_value)
        else
          return evaluate_expression(false_value)
        end
      end
      
      # Handle comparison operations as standalone expressions
      if expression =~ /^(.+?)\s*(==|!=|>=|<=|>|<)\s*(.+)$/
        condition_result = evaluate_condition(expression)
        return condition_result
      end
      
      nil
    end
    
    def evaluate_condition(condition)
      # Handle comparison operations
      if condition =~ /^(.+?)\s*(==|!=|>=|<=|>|<)\s*(.+)$/
        left_operand = $1.strip
        operator = $2.strip
        right_operand = $3.strip
        
        # Evaluate operands
        left_value = evaluate_operand(left_operand)
        right_value = evaluate_operand(right_operand)
        
        # Perform comparison
        case operator
        when '=='
          left_value == right_value
        when '!='
          left_value != right_value
        when '>='
          left_value >= right_value if left_value.respond_to?(:>=)
        when '<='
          left_value <= right_value if left_value.respond_to?(:<=)
        when '>'
          left_value > right_value if left_value.respond_to?(:>)
        when '<'
          left_value < right_value if left_value.respond_to?(:<)
        else
          false
        end
      else
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
    end
    
    def evaluate_operand(operand)
      # Handle string literals with quotes
      if operand =~ /^"([^"]*)"$/ || operand =~ /^'([^']*)'$/
        return $1
      elsif operand =~ /^-?\d+$/
        return operand.to_i
      elsif operand =~ /^-?\d*\.\d+$/
        return operand.to_f
      elsif operand == 'true'
        return true
      elsif operand == 'false'
        return false
      else
        # Variable lookup
        get_nested_variable(operand)
      end
    end
    
    def get_nested_variable(path)
      # Handle dot notation like "loop.index" or "items.length"
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
        elsif value.respond_to?(part) && (value.is_a?(Array) || value.is_a?(String))
          # Handle method calls like .length, .size, .count on arrays/strings only
          # Don't call methods on Hash objects to avoid conflicts with variable names
          begin
            value = value.send(part)
          rescue
            # If method call fails, return nil
            return nil
          end
        else
          return nil
        end
      end
      
      value
    end
  end
end
