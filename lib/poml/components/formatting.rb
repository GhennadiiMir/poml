module Poml
  # Bold component for emphasizing text
  class BoldComponent < Component
    def render
      apply_stylesheet
      content = @element.children.empty? ? @element.content : render_children
      
      if xml_mode? || @context.output_format == 'html'
        "<b>#{content}</b>"
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
      
      if xml_mode? || @context.output_format == 'html'
        "<i>#{content}</i>"
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
      
      if xml_mode? || @context.output_format == 'html'
        "<u>#{content}</u>"
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
      
      if xml_mode? || @context.output_format == 'html'
        "<s>#{content}</s>"
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
      
      if xml_mode? || @context.output_format == 'html'
        "<span>#{content}</span>"
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
      
      # Determine header level from tag name or attribute
      if @element.tag_name =~ /^h(\d)$/
        level = $1.to_i
      else
        level = get_attribute('level', @context.header_level).to_i
      end
      
      level = [level, 6].min # Cap at h6
      level = [level, 1].max # Minimum h1
      
      # Check output format preference
      if xml_mode? || @context.output_format == 'html'
        # HTML output format
        "<h#{level}>#{content}</h#{level}>"
      else
        # Default markdown format
        header_prefix = '#' * level
        if inline?
          content
        else
          "#{header_prefix} #{content}"
        end
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
      
      # In XML mode, selectively unescape only parsing artifacts while preserving intentional entities
      if xml_mode?
        # Unescape quotes that were escaped during parsing
        content = content.gsub('&quot;', '"').gsub('&apos;', "'")
        # Handle double-escaped HTML entities - restore single escaping
        content = content.gsub('&amp;lt;', '&lt;').gsub('&amp;gt;', '&gt;').gsub('&amp;amp;', '&amp;')
      end
      
      inline_attr = get_attribute('inline', true)
      lang = get_attribute('lang', '')
      
      # Determine if this should be inline:
      # - If the base 'inline' attribute is set and true, it's inline
      # - If the component-specific 'inline' attribute is set, use that
      # - Default to true for backwards compatibility
      is_inline = if has_attribute?('inline')
        get_attribute('inline') == 'true' || get_attribute('inline') == true
      else
        inline_attr == true || inline_attr == 'true'
      end
      
      if xml_mode?
        # Only include attributes that were explicitly provided in the XML
        attributes = {}
        attributes[:inline] = get_attribute('inline') if has_attribute?('inline')
        attributes[:lang] = lang unless lang.empty?
        render_as_xml('code', content, attributes)
      elsif @context.output_format == 'html'
        if is_inline
          "<code>#{content}</code>"
        else
          if lang.empty?
            "<pre><code>#{content}</code></pre>"
          else
            "<pre><code class=\"language-#{lang}\">#{content}</code></pre>"
          end
        end
      else
        if is_inline
          "`#{content}`"
        else
          result = if lang.empty?
            "```\n#{content}\n```\n\n"
          else
            "```#{lang}\n#{content}\n```\n\n"
          end
          inline? ? result.strip : result
        end
      end
    end

    private
    
    def has_attribute?(name)
      @element.attributes.key?(name.to_s) || @element.attributes.key?(name.to_s.downcase)
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

  # Code block component for multi-line code examples
  class CodeBlockComponent < Component
    def render
      apply_stylesheet
      
      language = get_attribute('language', '')
      content = @element.content
      
      # In XML mode, selectively unescape only quotes and ampersands that were 
      # escaped during parsing, but preserve intentional HTML entities like &lt; &gt;
      if xml_mode?
        # Unescape quotes that were escaped during parsing
        content = content.gsub('&quot;', '"').gsub('&apos;', "'")
        # Handle double-escaped HTML entities - restore single escaping  
        content = content.gsub('&amp;lt;', '&lt;').gsub('&amp;gt;', '&gt;').gsub('&amp;amp;', '&amp;')
        
        attributes = {}
        attributes[:language] = language unless language.empty?
        render_as_xml('code-block', content, attributes)
      else
        if language.empty?
          "```\n#{content}\n```"
        else
          "```#{language}\n#{content}\n```"
        end
      end
    end
  end

  # Callout component for highlighted information boxes
  class CalloutComponent < Component
    def render
      apply_stylesheet
      
      type = get_attribute('type', 'info')
      # If the element has children, render them (for mixed content like text + formatting)
      # Otherwise, use the element's direct content
      content = @element.children.empty? ? @element.content : render_children
      
      if xml_mode? || @context.output_format == 'html'
        "<div class=\"callout callout-#{type}\">#{content}</div>"
      else
        # Markdown-style callout
        prefix = case type.downcase
        when 'warning'
          '⚠️ '
        when 'error', 'danger'
          '❌ '
        when 'success'
          '✅ '
        else
          'ℹ️ '
        end
        
        "#{prefix}#{content}\n\n"
      end
    end
  end

  # Blockquote component for quoted content
  class BlockquoteComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      
      if xml_mode? || @context.output_format == 'html'
        "<blockquote>#{content}</blockquote>"
      else
        # Markdown-style blockquote
        lines = content.split("\n")
        quoted_lines = lines.map { |line| "> #{line}" }
        "#{quoted_lines.join("\n")}\n\n"
      end
    end
  end
end
