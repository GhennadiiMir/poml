module Poml
  # List component
  class ListComponent < Component
    def render
      apply_stylesheet
      
      if xml_mode?
        # In XML mode, lists don't exist - items are rendered directly
        @element.children.map do |child|
          if child.tag_name == :item
            Components.render_element(child, @context)
          end
        end.compact.join('')
      else
        list_style = get_attribute('listStyle', 'dash')
        items = []
        index = 0
        
        @element.children.each do |child|
          if child.tag_name == :item
            index += 1
            
            bullet = case list_style
            when 'decimal', 'number', 'numbered'
              "#{index}. "
            when 'star'
              "* "
            when 'plus'
              "+ "
            when 'dash', 'bullet', 'unordered'
              "- "
            else
              "- "
            end
            
            # Get text content and nested elements separately
            text_content = child.content.strip
            nested_elements = child.children.reject { |c| c.tag_name == :text }
            
            if nested_elements.any?
              # Item has both text and nested elements (like nested lists)
              nested_content = nested_elements.map { |nested_child| 
                Components.render_element(nested_child, @context) 
              }.join('').strip
              
              # Format with text content on first line, nested content indented
              indented_nested = nested_content.split("\n").map { |line| 
                line.strip.empty? ? "" : "   #{line}" 
              }.join("\n").strip
              
              if text_content.empty?
                items << "#{bullet}#{indented_nested}"
              else
                items << "#{bullet}#{text_content} \n\n#{indented_nested}"
              end
            else
              # Simple text-only item
              items << "#{bullet}#{text_content}"
            end
          end
        end
        
        return "\n\n" if items.empty?
        items.join("\n") + "\n\n"
      end
    end
  end

  # Item component (for list items)
  class ItemComponent < Component
    def render
      apply_stylesheet
      content = @element.content.empty? ? render_children : @element.content.strip
      
      if xml_mode?
        "<item>#{content}</item>\n"
      else
        content
      end
    end
  end
end
