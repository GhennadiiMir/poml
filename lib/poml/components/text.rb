module Poml
  # Text component for plain text content
  class TextComponent < Component
    def render
      @element.content
    end
  end
end
