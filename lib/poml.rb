# frozen_string_literal: true

require_relative "poml/version"
require_relative 'poml/context'
require_relative 'poml/template_engine'
require_relative 'poml/parser'
require_relative 'poml/renderer'
require_relative 'poml/components'

module Poml
  class Error < StandardError; end

  # Main entry point for processing POML files
  # Parameters:
  # - markup: POML file path or string content
  # - context: Hash of variables for template substitution
  # - stylesheet: Optional stylesheet as string or hash
  # - chat: Boolean indicating chat format (default: true)
  # - output_file: Path to save output (optional)
  # Process POML markup and return the rendered result
  # 
  # Parameters:
  # - markup: POML markup string or file path
  # - format: 'raw', 'dict', 'openai_chat', 'openaiResponse', 'langchain', 'pydantic' (default: 'dict')
  # - context/variables: Hash of template variables
  # - stylesheet: CSS/styling rules
  # - chat: Enable chat mode (default: true)
  # - output_file: File path to write output to
  def self.process(markup:, format: 'dict', **options)
    # Handle file paths
    source_file = nil
    content = if File.exist?(markup)
      source_file = File.expand_path(markup)
      File.read(markup)
    else
      markup
    end
    
    # Extract output file option
    output_file = options.delete(:output_file)
    
    # Extract context from various parameter formats
    if options.key?(:context)
      # If context is provided explicitly, use it as variables
      context_options = {}
      context_options[:variables] = options.delete(:context)
    else
      # Extract known context options and ignore unknown ones
      context_options = {}
      context_options[:variables] = options.delete(:variables) || options.reject { |k, v| [:stylesheet, :chat, :syntax].include?(k) }
    end
    
    context_options[:stylesheet] = options.delete(:stylesheet) if options.key?(:stylesheet)
    context_options[:chat] = options.delete(:chat) if options.key?(:chat)
    context_options[:syntax] = options.delete(:syntax) if options.key?(:syntax)
    context_options[:source_path] = source_file if source_file
    
    result = render(content, format: format, **context_options)
    
    # Write to file if output_file is specified
    if output_file
      File.write(output_file, result)
      '' # Return empty string when writing to file
    else
      result
    end
  end

  def self.parse(content, context: nil)
    context ||= Context.new
    parser = Parser.new(context)
    parser.parse(content)
  end

  def self.render(content, format: 'text', context: nil, **options)
    context ||= Context.new(**options)
    elements = parse(content, context: context)
    renderer = Renderer.new(context)
    renderer.render(elements, format)
  end

  # Convenience method for quick text rendering
  def self.to_text(content, **options)
    render(content, format: 'raw', **options)
  end

  # Convenience method for chat format
  def self.to_chat(content, **options)
    render(content, format: 'openai_chat', **options)
  end

  # Convenience method for OpenAI response format
  def self.to_openai_response(content, **options)
    render(content, format: 'openaiResponse', **options)
  end

  # Convenience method for dict format
  def self.to_dict(content, **options)
    render(content, format: 'dict', **options)
  end

  # Convenience method for Pydantic format with Python interoperability
  def self.to_pydantic(content, **options)
    render(content, format: 'pydantic', **options)
  end
end
