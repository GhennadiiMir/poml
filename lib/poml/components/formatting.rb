module Poml
  # Bold component for emphasizing text
  class BoldComponent < Component
    def render
      apply_stylesheet
      content = @element.children.empty? ? @element.content : render_children
      
      if xml_mode?
        render_as_xml('b', content)
      else
        "**#{content}**"
      end
    end
  end

  # Italic component for emphasizing text
  class ItalicComponent < Component
    def render
      apply_stylesheet
      content = @element.children.empty? ? @element.content : render_children
      
      if xml_mode?
        render_as_xml('i', content)
      else
        "*#{content}*"
      end
    end
  end

  # Underline component for underlining text
  class UnderlineComponent < Component
    def render
      apply_stylesheet
      content = @element.children.empty? ? @element.content : render_children
      
      if xml_mode?
        render_as_xml('u', content)
      else
        # Markdown-style underline
        "__#{content}__"
      end
    end
  end

  # Strikethrough component for crossed-out text
  class StrikethroughComponent < Component
    def render
      apply_stylesheet
      content = @element.children.empty? ? @element.content : render_children
      
      if xml_mode?
        render_as_xml('s', content)
      else
        "~~#{content}~~"
      end
    end
  end

  # Inline span component for generic inline content
  class InlineComponent < Component
    def render
      apply_stylesheet
      content = @element.content.empty? ? render_children : @element.content
      
      if xml_mode?
        render_as_xml('span', content)
      else
        content
      end
    end
  end

  # Header component for headings
  class HeaderComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      level = get_attribute('level', @context.header_level).to_i
      level = [level, 6].min # Cap at h6
      level = [level, 1].max # Minimum h1
      
      if xml_mode?
        render_as_xml('h', content, { level: level })
      else
        header_prefix = '#' * level
        "#{header_prefix} #{content}\n\n"
      end
    end
  end

  # Newline component for explicit line breaks
  class NewlineComponent < Component
    def render
      apply_stylesheet
      
      count = get_attribute('newLineCount', 1).to_i
      
      if xml_mode?
        render_as_xml('nl', '', { count: count })
      else
        "\n" * count
      end
    end
  end

  # Code component for code snippets
  class CodeComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      inline = get_attribute('inline', true)
      lang = get_attribute('lang', '')
      
      if xml_mode?
        attributes = { inline: inline }
        attributes[:lang] = lang unless lang.empty?
        render_as_xml('code', content, attributes)
      else
        if inline
          "`#{content}`"
        else
          if lang.empty?
            "```\n#{content}\n```\n\n"
          else
            "```#{lang}\n#{content}\n```\n\n"
          end
        end
      end
    end
  end

  # SubContent component for nested sections
  class SubContentComponent < Component
    def render
      apply_stylesheet
      
      content = @context.with_increased_header_level { render_children }
      
      if xml_mode?
        render_as_xml('section', content)
      else
        "#{content}"
      end
    end
  end
end
