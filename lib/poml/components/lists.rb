module Poml
  # List component
  class ListComponent < Component
    def render
      apply_stylesheet
      
      if xml_mode?
        # In XML mode, preserve list structure with proper wrapping
        list_style = if @element.tag_name.to_s == 'numbered-list'
          'decimal'
        else
          get_attribute('listStyle', 'dash')
        end
        
        items_content = @element.children.map do |child|
          if child.tag_name == :item
            Components.render_element(child, @context)
          end
        end.compact.join('')
        
        if @element.tag_name.to_s == 'numbered-list'
          "<numbered-list style=\"#{list_style}\">\n#{items_content}</numbered-list>\n"
        else
          "<list style=\"#{list_style}\">\n#{items_content}</list>\n"
        end
      else
        # Store list style in context for child components to use
        original_list_style = @context.instance_variable_get(:@list_style)
        original_list_index = @context.instance_variable_get(:@list_index)
        
        # Determine list style - check if this is a numbered list
        list_style = if @element.tag_name.to_s == 'numbered-list'
          'numbered'
        else
          get_attribute('listStyle', 'dash')
        end
        
        @context.instance_variable_set(:@list_style, list_style)
        @context.instance_variable_set(:@list_index, 0)
        
        # Render all children - they will auto-format as list items
        content = @element.children.map do |child|
          Components.render_element(child, @context)
        end.join('')
        
        # Restore original context
        @context.instance_variable_set(:@list_style, original_list_style)
        @context.instance_variable_set(:@list_index, original_list_index)
        
        return "\n\n" if content.strip.empty?
        
        if inline?
          content
        else
          content + "\n\n"
        end
      end
    end
  end

  # Item component (for list items)
  class ItemComponent < Component
    def render
      apply_stylesheet
      
      if xml_mode?
        # Always render children to properly handle mixed content (text + components)
        content = render_children
        "<item>#{content}</item>\n"
      else
        # For raw mode, handle mixed content properly
        content = if @element.children.any?
          # Render text and child elements together
          result = ""
          @element.children.each do |child|
            if child.text?
              result += child.content
            else
              result += Components.render_element(child, @context)
            end
          end
          result.strip
        else
          @element.content.strip
        end
        
        # Check if we're inside a list and format accordingly
        list_style = @context.instance_variable_get(:@list_style)
        if list_style
          current_index = @context.instance_variable_get(:@list_index) || 0
          new_index = current_index + 1
          @context.instance_variable_set(:@list_index, new_index)
          
          bullet = case list_style
          when 'decimal', 'number', 'numbered'
            "#{new_index}. "
          when 'star'
            "* "
          when 'plus'
            "+ "
          when 'dash', 'bullet', 'unordered'
            "- "
          else
            "- "
          end
          
          "#{bullet}#{content}\n"
        else
          content
        end
      end
    end
  end
end
