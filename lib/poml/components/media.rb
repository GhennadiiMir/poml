module Poml
  # Audio component for embedding audio files
  class AudioComponent < Component
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      base64 = get_attribute('base64')
      alt = get_attribute('alt', '')
      audio_type = get_attribute('type', '')
      syntax = get_attribute('syntax', 'multimedia')
      position = get_attribute('position', 'here')
      
      if xml_mode?
        attributes = {}
        attributes[:src] = src if src
        attributes[:base64] = base64 if base64
        attributes[:alt] = alt unless alt.empty?
        attributes[:type] = audio_type unless audio_type.empty?
        attributes[:position] = position
        render_as_xml('audio', '', attributes)
      else
        if syntax == 'multimedia'
          audio_ref = src || '[embedded audio]'
          result = "[Audio: #{audio_ref}]"
          result += " (#{alt})" unless alt.empty?
          result
        else
          alt.empty? ? '[Audio]' : alt
        end
      end
    end
  end
end
