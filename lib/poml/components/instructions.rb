module Poml
  # Role component
  class RoleComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content

      if xml_mode?
        render_as_xml('role', content)
      else
        caption = apply_text_transform(get_attribute('caption', 'Role'))
        caption_style = get_attribute('captionStyle', 'header')

        case caption_style
        when 'header'
          "# #{caption}\n\n#{content}\n\n"
        when 'bold'
          "**#{caption}:** #{content}\n\n"
        when 'plain'
          "#{caption}: #{content}\n\n"
        when 'hidden'
          "#{content}\n\n"
        else
          "# #{caption}\n\n#{content}\n\n"
        end
      end
    end
  end

  # Task component
  class TaskComponent < Component
    def render
      apply_stylesheet
      
      # For mixed content (text + elements), preserve spacing
      content = if @element.children.empty?
        @element.content.strip
      else
        # Don't strip when there are children to preserve spacing between text and elements
        render_children
      end

      if xml_mode?
        render_as_xml('task', content)
      else
        caption = apply_text_transform(get_attribute('caption', 'Task'))
        caption_style = get_attribute('captionStyle', 'header')

        case caption_style
        when 'header'
          # Don't add extra newlines if content already ends with newlines
          content_ending = content.end_with?("\n\n") ? "" : "\n\n"
          "# #{caption}\n\n#{content}#{content_ending}"
        when 'bold'
          "**#{caption}:** #{content}\n\n"
        when 'plain'
          "#{caption}: #{content}\n\n"
        when 'hidden'
          content_ending = content.end_with?("\n\n") ? "" : "\n\n"
          "#{content}#{content_ending}"
        else
          content_ending = content.end_with?("\n\n") ? "" : "\n\n"
          "# #{caption}\n\n#{content}#{content_ending}"
        end
      end
    end
  end

  # Hint component
  class HintComponent < Component
    def render
      apply_stylesheet
      
      caption = get_attribute('caption', 'Hint')
      caption_style = get_attribute('captionStyle', 'header')
      content = @element.content.empty? ? render_children : @element.content

      case caption_style
      when 'header'
        "# #{caption}\n\n#{content}\n\n"
      when 'bold'
        "**#{caption}:** #{content}\n\n"
      when 'plain'
        "#{caption}: #{content}\n\n"
      when 'hidden'
        "#{content}\n\n"
      else
        "# #{caption}\n\n#{content}\n\n"
      end
    end
  end
end
