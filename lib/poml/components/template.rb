module Poml
  # Conditional component for if-then logic
  class IfComponent < Component
    def render
      apply_stylesheet
      
      condition = get_attribute('condition')
      return '' unless condition
      
      # Evaluate the condition
      if evaluate_condition(condition)
        # Render child content
        @element.children.map do |child|
          Components.render_element(child, @context)
        end.join('')
      else
        ''
      end
    end
    
    private
    
    def evaluate_condition(condition)
      # Handle both raw variable names and template expressions
      condition = condition.strip
      
      # Check for negation operator at the beginning
      negate = false
      if condition.start_with?('!')
        negate = true
        condition = condition[1..-1].strip
      end
      
      # First, substitute any template variables in the condition
      substituted_condition = @context.template_engine.substitute(condition)
      
      # Evaluate the condition
      result = case substituted_condition
      when 'true'
        true
      when 'false'
        false
      when /^(.+?)\s*(>=|<=|==|!=|>|<)\s*(.+)$/
        # Handle comparison operators
        left_operand = $1.strip
        operator = $2.strip
        right_operand = $3.strip
        
        # Convert operands to appropriate types
        left_value = convert_operand(left_operand)
        right_value = convert_operand(right_operand)
        
        # Perform comparison
        case operator
        when '>'
          compare_values(left_value, right_value, :>)
        when '<'
          compare_values(left_value, right_value, :<)
        when '>='
          compare_values(left_value, right_value, :>=)
        when '<='
          compare_values(left_value, right_value, :<=)
        when '=='
          left_value == right_value
        when '!='
          left_value != right_value
        else
          false
        end
      when /^{{(.+)}}$/
        # Extract the variable name and evaluate it directly
        var_name = $1.strip
        result = @context.template_engine.evaluate_attribute_expression(var_name)
        convert_to_boolean(result)
      else
        # Try to evaluate as a variable name
        result = @context.template_engine.evaluate_attribute_expression(substituted_condition)
        convert_to_boolean(result)
      end
      
      # Apply negation if needed
      negate ? !result : result
    end
    
    def convert_operand(operand)
      # First substitute any template variables
      substituted = @context.template_engine.substitute(operand)
      
      # Handle quoted strings
      if substituted =~ /^['"](.*)['"]$/
        return $1
      end
      
      # Try to convert to number if possible, otherwise keep as string
      if substituted =~ /^-?\d+$/
        substituted.to_i
      elsif substituted =~ /^-?\d*\.\d+$/
        substituted.to_f
      else
        substituted
      end
    end
    
    def compare_values(left, right, operator)
      # Handle type mismatches gracefully
      begin
        left.send(operator, right)
      rescue ArgumentError
        # If types are incompatible, try to convert both to strings and compare
        left.to_s.send(operator, right.to_s)
      end
    end
    
    def convert_to_boolean(result)
      case result
      when true, false
        result
      when nil, 0, '', []
        false
      when 'true'
        true
      when 'false'
        false
      else
        true
      end
    end
  end
  
  # Loop component for iterating over arrays
  class ForComponent < Component
    def render
      apply_stylesheet
      
      variable = get_attribute('variable')
      items_expr = get_attribute('items')
      
      return '' unless variable && items_expr
      
      # Evaluate the items expression
      items = evaluate_items(items_expr)
      return '' unless items.is_a?(Array)
      
      # Render content for each item without mutating original elements
      results = []
      items.each_with_index do |item, index|
        # Create child context with loop variable
        child_context = @context.create_child_context
        child_context.variables[variable] = item
        child_context.variables['loop'] = { 'index' => index + 1 }  # 1-based index
        
        # Update template engine context to use new variables
        child_context.template_engine = Poml::TemplateEngine.new(child_context)
        
        # Ensure list index is synchronized with parent context
        if @context.instance_variable_get(:@list_style)
          # Copy current list index from parent to child before processing
          current_list_index = @context.instance_variable_get(:@list_index) || 0
          child_context.instance_variable_set(:@list_index, current_list_index)
        end
        
        # Process each child element in the child context
        item_content = @element.children.map do |child|
          # Create a deep copy of the child element to avoid mutations
          child_copy = deep_copy_element(child)
          
          # Process templates in the copied element
          process_templates_in_element(child_copy, child_context)
          
          # Render the processed element
          Components.render_element(child_copy, child_context)
        end.join('')
        
        # Update parent context with the list index from child context
        if @context.instance_variable_get(:@list_style)
          updated_list_index = child_context.instance_variable_get(:@list_index)
          @context.instance_variable_set(:@list_index, updated_list_index)
        end
        
        results << item_content
      end
      
      results.join('')
    end
    
    private
    
    def deep_copy_element(element)
      # Create a new element with the same properties
      Element.new(
        tag_name: element.tag_name,
        attributes: element.attributes.dup,
        content: element.content.dup,
        children: element.children.map { |child| deep_copy_element(child) }
      )
    end
    
    def process_templates_in_element(element, context)
      # Process template variables in the element's content
      if element.content && element.content.include?('{{')
        element.content = context.template_engine.substitute(element.content)
      end
      
      # Recursively process templates in children
      element.children.each do |child|
        process_templates_in_element(child, context)
      end
    end
    
    def evaluate_items(items_expr)
      # Handle both raw variable names and template expressions
      items_expr = items_expr.strip
      
      case items_expr
      when /^{{(.+)}}$/
        # Extract the variable name and evaluate it directly
        var_name = $1.strip
        @context.template_engine.evaluate_attribute_expression(var_name)
      else
        # Try to evaluate as a variable name or expression
        @context.template_engine.evaluate_attribute_expression(items_expr)
      end
    end
  end
  
  # Include component for including other POML files
  class IncludeComponent < Component
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      return '[Include: no src specified]' unless src
      
      # Handle conditional and loop attributes
      if_condition = @element.attributes['if']
      for_attribute = @element.attributes['for']
      
      # Check if condition
      if if_condition && !evaluate_if_condition(if_condition)
        return ''
      end
      
      # Handle for loop
      if for_attribute
        return render_with_for_loop(src, for_attribute)
      end
      
      # Simple include
      include_file(src)
    end
    
    private
    
    def include_file(src)
      begin
        # Resolve file path
        file_path = if src.start_with?('/')
          src
        else
          base_path = @context.source_path ? File.dirname(@context.source_path) : Dir.pwd
          File.join(base_path, src)
        end
        
        unless File.exist?(file_path)
          return "[Include: #{src} (not found)]"
        end
        
        # Read and parse the included file
        included_content = File.read(file_path)
        
        # Create a new parser context with current variables
        included_context = @context.create_child_context
        included_context.source_path = file_path
        
        parser = Parser.new(included_context)
        elements = parser.parse(included_content)
        
        # Render the included elements
        elements.map { |element| Components.render_element(element, included_context) }.join('')
        
      rescue => e
        "[Include: #{src} (error: #{e.message})]"
      end
    end
    
    def render_with_for_loop(src, for_attribute)
      # Parse for attribute like "i in [1,2,3]" or "item in items"
      if for_attribute =~ /^(\w+)\s+in\s+(.+)$/
        loop_var = $1
        list_expr = $2.strip
        
        # Evaluate the list expression
        list = @context.template_engine.evaluate_attribute_expression(list_expr)
        return '' unless list.is_a?(Array)
        
        # Render for each item in the list
        results = []
        list.each_with_index do |item, index|
          # Create loop context
          old_loop_var = @context.variables[loop_var]
          old_loop_context = @context.variables['loop']
          
          @context.variables[loop_var] = item
          @context.variables['loop'] = {
            'index' => index,
            'length' => list.length,
            'first' => index == 0,
            'last' => index == list.length - 1
          }
          
          # Include the file with current loop context
          result = include_file(src)
          results << result
          
          # Restore previous context
          if old_loop_var
            @context.variables[loop_var] = old_loop_var
          else
            @context.variables.delete(loop_var)
          end
          
          if old_loop_context
            @context.variables['loop'] = old_loop_context
          else
            @context.variables.delete('loop')
          end
        end
        
        results.join('')
      else
        "[Include: invalid for syntax: #{for_attribute}]"
      end
    end
    
    def evaluate_if_condition(condition)
      value = @context.template_engine.evaluate_attribute_expression(condition)
      !!value
    end
  end
end
