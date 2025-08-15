module Poml
  # Example component
  class ExampleComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      "#{content}\n\n"
    end
  end

  # Input component (for examples)
  class InputComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      "#{content}\n\n"
    end
  end

  # Output component (for examples)
  class OutputComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      "#{content}\n\n"
    end
  end

  # Output format component
  class OutputFormatComponent < Component
    def render
      apply_stylesheet
      
      caption = get_attribute('caption', 'Output Format')
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
