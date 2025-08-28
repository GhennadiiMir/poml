require 'json'
require 'set'

module Poml
  # Context object that holds variables, stylesheets, and processing state
  class Context
    attr_accessor :variables, :stylesheet, :chat, :texts, :source_path, :syntax, :header_level
    attr_accessor :response_schema, :tools, :runtime_parameters, :disabled_components
    attr_accessor :template_engine, :chat_messages, :custom_metadata

    def initialize(variables: {}, stylesheet: nil, chat: true, syntax: nil, source_path: nil)
      @variables = variables || {}
      @stylesheet = parse_stylesheet(stylesheet)
      @chat = chat
      @texts = {}
      @source_path = source_path
      @syntax = syntax
      @header_level = 1 # Track current header nesting level
      @response_schema = nil
      @tools = []
      @runtime_parameters = {}
      @disabled_components = Set.new
      @template_engine = TemplateEngine.new(self)
      @chat_messages = [] # Track structured chat messages
      @custom_metadata = {} # Track general metadata like title, description etc.
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
      result = yield
      @header_level = old_level
      result
    end

    def with_chat_context(chat_enabled)
      old_chat = @chat
      @chat = chat_enabled
      result = yield
      @chat = old_chat
      result
    end

    def create_child_context
      child = Context.new(
        variables: @variables.dup,
        stylesheet: @stylesheet.dup,
        chat: @chat,
        syntax: @syntax
      )
      child.header_level = @header_level
      child.response_schema = @response_schema
      child.tools = @tools.dup
      child.runtime_parameters = @runtime_parameters.dup
      child.disabled_components = @disabled_components.dup
      child.chat_messages = @chat_messages # Share the same array reference
      child.custom_metadata = @custom_metadata # Share the same hash reference
      child
    end

    def component_enabled?(component_name)
      !@disabled_components.include?(component_name.to_s)
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
