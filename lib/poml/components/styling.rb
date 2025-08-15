module Poml
  # Let component (for variable definitions)
  class LetComponent < Component
    def render
      apply_stylesheet
      
      name = get_attribute('name')
      value = @element.content.empty? ? render_children : @element.content
      
      # Add to context variables
      @context.variables[name] = value if name
      
      # Let components produce no output
      ''
    end
  end

  # Stylesheet component
  class StylesheetComponent < Component
    def render
      # Parse and apply stylesheet
      begin
        stylesheet_content = @element.content.strip
        if stylesheet_content.start_with?('{') && stylesheet_content.end_with?('}')
          stylesheet = JSON.parse(stylesheet_content)
          @context.stylesheet.merge!(stylesheet) if stylesheet.is_a?(Hash)
        end
      rescue => e
        # Silently fail JSON parsing errors
      end
      
      # Stylesheet components don't produce output
      ''
    end
  end
end
