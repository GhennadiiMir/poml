require 'json'

module Poml
  # Context object that holds variables, stylesheets, and processing state
  class Context
    attr_accessor :variables, :stylesheet, :chat, :texts, :source_path, :syntax, :header_level

    def initialize(variables: {}, stylesheet: nil, chat: true, syntax: nil)
      @variables = variables || {}
      @stylesheet = parse_stylesheet(stylesheet)
      @chat = chat
      @texts = {}
      @source_path = nil
      @syntax = syntax
      @header_level = 1 # Track current header nesting level
    end

    def xml_mode?
      @syntax == 'xml'
    end

    def determine_syntax(element)
      # Check if element or parent has syntax specified
      element_syntax = element.attributes['syntax'] if element.respond_to?(:attributes)
      element_syntax || @syntax || 'markdown'
    end

    def with_increased_header_level
      old_level = @header_level
      @header_level += 1
      yield
    ensure
      @header_level = old_level
    end

    private

    def parse_stylesheet(stylesheet)
      case stylesheet
      when Hash
        stylesheet
      when String
        JSON.parse(stylesheet)
      when nil
        {}
      else
        {}
      end
    rescue JSON::ParserError
      {}
    end
  end
end
