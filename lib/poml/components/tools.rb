module Poml
  # Tools wrapper component that contains tool definitions
  class ToolsComponent < Component
    def render
      # Process child tool elements
      @element.children.each do |child|
        Components.render_element(child, @context)
      end
      
      # Tools components don't produce output by default
      ''
    end
  end
end
