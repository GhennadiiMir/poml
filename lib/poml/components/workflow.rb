module Poml
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
end
