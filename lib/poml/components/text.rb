module Poml
  # Text component for plain text content
  class TextComponent < Component
    def render
      @element.content
    end
  end

  # Unknown component handler - preserves tag name and content for debugging
  class UnknownComponent < Component
    def render
      apply_stylesheet
      
      tag_name = @element.tag_name.to_s
      content = @element.children.empty? ? @element.content : render_children
      
      if xml_mode?
        # In XML mode, preserve the original tag
        render_as_xml(tag_name, content)
      else
        # In text mode, include both tag name and content for debugging
        "#{tag_name}: #{content}"
      end
    end
  end
end
