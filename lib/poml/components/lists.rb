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
            
            # Render all content (text + formatting) together
            content = if child.children.any?
              Components.render_element(child, @context).strip
            else
              child.content.strip
            end
            
            items << "#{bullet}#{content}"
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
      
      if xml_mode?
        content = @element.content.empty? ? render_children : @element.content.strip
        "<item>#{content}</item>\n"
      else
        # For raw mode, handle mixed content properly
        if @element.children.any?
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
      end
    end
  end
end
