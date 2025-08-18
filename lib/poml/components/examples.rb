module Poml
  # Example component
  class ExampleComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      caption = get_attribute('caption', 'Example')
      caption_style = get_attribute('captionStyle', 'hidden')
      chat = get_attribute('chat', nil)
      
      if xml_mode?
        render_as_xml('example', content)
      else
        # Determine if chat format should be used
        if chat.nil?
          # Auto-detect: use chat format for markup syntaxes by default
          use_chat = @context.determine_syntax(@element) != 'xml'
        else
          use_chat = chat
        end
        
        if use_chat && caption_style == 'hidden'
          content
        else
          case caption_style
          when 'header'
            "## #{caption}\n\n#{content}\n\n"
          when 'bold'
            "**#{caption}:** #{content}\n\n"
          when 'plain'
            "#{caption}: #{content}\n\n"
          when 'hidden'
            "#{content}\n\n"
          else
            "#{content}\n\n"
          end
        end
      end
    end
  end

  # Input component (for examples)
  class InputComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      caption = get_attribute('caption', 'Input')
      caption_style = get_attribute('captionStyle', 'hidden')
      speaker = get_attribute('speaker', 'human')
      
      if xml_mode?
        render_as_xml('input', content, { speaker: speaker })
      else
        case caption_style
        when 'header'
          "## #{caption}\n\n#{content}\n\n"
        when 'bold'
          "**#{caption}:** #{content}\n\n"
        when 'plain'
          "#{caption}: #{content}\n\n"
        when 'hidden'
          "#{content}\n\n"
        else
          "#{content}\n\n"
        end
      end
    end
  end

  # Output component (for examples)
  class OutputComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      caption = get_attribute('caption', 'Output')
      caption_style = get_attribute('captionStyle', 'hidden')
      speaker = get_attribute('speaker', 'ai')
      
      if xml_mode?
        render_as_xml('output', content, { speaker: speaker })
      else
        case caption_style
        when 'header'
          "## #{caption}\n\n#{content}\n\n"
        when 'bold'
          "**#{caption}:** #{content}\n\n"
        when 'plain'
          "#{caption}: #{content}\n\n"
        when 'hidden'
          "#{content}\n\n"
        else
          "#{content}\n\n"
        end
      end
    end
  end

  # Example set component for managing multiple examples
  class ExampleSetComponent < Component
    def render
      apply_stylesheet
      
      caption = get_attribute('caption', 'Examples')
      caption_style = get_attribute('captionStyle', 'header')
      chat = get_attribute('chat', true)
      introducer = get_attribute('introducer', '')
      
      content = @context.with_chat_context(chat) { render_children }
      
      if xml_mode?
        render_as_xml('examples', content)
      else
        result = []
        
        case caption_style
        when 'header'
          result << "# #{caption}"
        when 'bold'
          result << "**#{caption}:**"
        when 'plain'
          result << "#{caption}:"
        when 'hidden'
          # No caption
        else
          result << "# #{caption}"
        end
        
        result << "" unless result.empty? # Add blank line after caption
        
        unless introducer.empty?
          result << introducer
          result << ""
        end
        
        result << content
        result << ""
        
        result.join("\n")
      end
    end
  end

  # Output format component
  class OutputFormatComponent < Component
    def render
      apply_stylesheet
      
      caption = get_attribute('caption', 'Output Format')
      caption_style = get_attribute('captionStyle', 'header')
      content = @element.content.empty? ? render_children : @element.content

      if xml_mode?
        render_as_xml('outputFormat', content)
      else
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

  # Introducer component
  class IntroducerComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      caption = get_attribute('caption', 'Introducer')
      caption_style = get_attribute('captionStyle', 'hidden')
      
      if xml_mode?
        render_as_xml('introducer', content)
      else
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
          "#{content}\n\n"
        end
      end
    end
  end
end
