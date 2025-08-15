# Main components file - requires all component modules
require_relative 'components/base'
require_relative 'components/text'
require_relative 'components/instructions'
require_relative 'components/content'
require_relative 'components/data'

# TODO: Create remaining component files:
# require_relative 'components/examples'    # ExampleComponent, InputComponent, OutputComponent, OutputFormatComponent
# require_relative 'components/lists'       # ListComponent, ItemComponent  
# require_relative 'components/layout'      # CPComponent (CaptionedParagraph)
# require_relative 'components/workflow'    # StepwiseInstructionsComponent, HumanMessageComponent, QAComponent
# require_relative 'components/styling'     # StylesheetComponent, LetComponent

# Temporary: Keep remaining components inline until they are split out
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

  # List component
  class ListComponent < Component
    def render
      apply_stylesheet
      
      if xml_mode?
        # In XML mode, lists don't exist - items are rendered directly
        @element.children.map do |child|
          if child.tag_name == :item
            Components.render_element(child, @context)
          end
        end.compact.join('')
      else
        list_style = get_attribute('listStyle', 'dash')
        items = []
        index = 0
        
        @element.children.each do |child|
          if child.tag_name == :item
            index += 1
            
            bullet = case list_style
            when 'decimal', 'number', 'numbered'
              "#{index}. "
            when 'star'
              "* "
            when 'plus'
              "+ "
            when 'dash', 'bullet', 'unordered'
              "- "
            else
              "- "
            end
            
            # Get text content and nested elements separately
            text_content = child.content.strip
            nested_elements = child.children.reject { |c| c.tag_name == :text }
            
            if nested_elements.any?
              # Item has both text and nested elements (like nested lists)
              nested_content = nested_elements.map { |nested_child| 
                Components.render_element(nested_child, @context) 
              }.join('').strip
              
              # Format with text content on first line, nested content indented
              indented_nested = nested_content.split("\n").map { |line| 
                line.strip.empty? ? "" : "   #{line}" 
              }.join("\n").strip
              
              if text_content.empty?
                items << "#{bullet}#{indented_nested}"
              else
                items << "#{bullet}#{text_content} \n\n#{indented_nested}"
              end
            else
              # Simple text-only item
              items << "#{bullet}#{text_content}"
            end
          end
        end
        
        return "\n\n" if items.empty?
        items.join("\n") + "\n\n"
      end
    end
  end

  # Item component (for list items)
  class ItemComponent < Component
    def render
      apply_stylesheet
      content = @element.content.empty? ? render_children : @element.content.strip
      
      if xml_mode?
        "<item>#{content}</item>\n"
      else
        content
      end
    end
  end

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

  # Stepwise Instructions component
  class StepwiseInstructionsComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content

      if xml_mode?
        render_as_xml('stepwise-instructions', content)
      else
        caption = apply_text_transform(get_attribute('caption', 'Stepwise Instructions'))
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

  # Human Message component
  class HumanMessageComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      speaker = get_attribute('speaker', 'human')

      if xml_mode?
        render_as_xml('human-message', content)
      else
        "#{content}\n\n"
      end
    end
  end

  # Question-Answer component
  class QAComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      question_caption = get_attribute('questionCaption', 'Question')
      answer_caption = get_attribute('answerCaption', 'Answer')

      if xml_mode?
        render_as_xml('qa', content)
      else
        "**#{question_caption}:** #{content}\n\n**#{answer_caption}:**"
      end
    end
  end

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
