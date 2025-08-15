# frozen_string_literal: true

require_relative "poml/version"
require_relative 'poml/context'
require_relative 'poml/parser'
require_relative 'poml/renderer'
require_relative 'poml/components'
require_relative 'poml/template_engine'

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
end
