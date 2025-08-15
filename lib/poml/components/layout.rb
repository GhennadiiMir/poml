module Poml
  # CP component (custom component with caption)
  class CPComponent < Component
    def render
      apply_stylesheet
      
      caption = get_attribute('caption', '')
      caption_serialized = get_attribute('captionSerialized', caption)
      
      # Render children with increased header level for nested CPs
      content = if @element.content.empty?
        @context.with_increased_header_level { render_children }
      else
        @element.content
      end

      if xml_mode?
        # Use captionSerialized for XML tag name, fallback to caption
        tag_name = caption_serialized.empty? ? caption : caption_serialized
        return render_as_xml(tag_name, content) unless tag_name.empty?
        # If no caption, just return content
        return "#{content}\n\n"
      else
        caption_style = get_attribute('captionStyle', 'header')
        # Use captionSerialized for the actual header if provided
        display_caption = caption_serialized.empty? ? caption : caption_serialized
        
        # Apply stylesheet text transformation
        display_caption = apply_text_transform(display_caption)
        
        return content + "\n\n" if display_caption.empty?

        case caption_style
        when 'header'
          header_prefix = '#' * @context.header_level
          "#{header_prefix} #{display_caption}\n\n#{content}\n\n"
        when 'bold'
          "**#{display_caption}:** #{content}\n\n"
        when 'plain'
          "#{display_caption}: #{content}\n\n"
        when 'hidden'
          "#{content}\n\n"
        else
          header_prefix = '#' * @context.header_level
          "#{header_prefix} #{display_caption}\n\n#{content}\n\n"
        end
      end
    end
  end
end
