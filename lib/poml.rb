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
  # - format: 'raw', 'dict', 'openai_chat', 'langchain', 'pydantic' (default: 'dict')
  # - extra_args: Array of extra CLI args (ignored in pure Ruby implementation)
  def self.process(markup:, context: nil, stylesheet: nil, chat: true, output_file: nil, format: 'dict', extra_args: [])
    # Create POML context
    poml_context = Context.new(
      variables: context || {},
      stylesheet: stylesheet,
      chat: chat
    )

    # Read markup content and set source path
    content = if File.exist?(markup.to_s)
      poml_context.source_path = File.expand_path(markup.to_s)
      File.read(markup)
    else
      markup.to_s
    end

    # Parse POML content
    parser = Parser.new(poml_context)
    parsed_elements = parser.parse(content)

    # Render to the desired format
    renderer = Renderer.new(poml_context)
    result = renderer.render(parsed_elements, format)

    # Save to file if specified
    if output_file
      File.write(output_file, result)
    end

    result
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

  # Convenience method for dict format
  def self.to_dict(content, **options)
    render(content, format: 'dict', **options)
  end
  
  # Legacy method for backward compatibility
  def self.process(markup:, format: 'dict', **options)
    # Handle file paths
    content = if File.exist?(markup)
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
    
    result = render(content, format: format, **context_options)
    
    # Write to file if output_file is specified
    if output_file
      File.write(output_file, result)
      '' # Return empty string when writing to file
    else
      result
    end
  end
end
