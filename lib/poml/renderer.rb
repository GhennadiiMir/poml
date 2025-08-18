require 'json'

module Poml
  # Renderer converts parsed POML elements to various output formats
  class Renderer
    def initialize(context)
      @context = context
    end

    def render(elements, format = 'dict')
      case format
      when 'raw'
        render_raw(elements)
      when 'dict'
        render_dict(elements)
      when 'openai_chat'
        render_openai_chat(elements)
      when 'langchain'
        render_langchain(elements)
      when 'pydantic'
        render_pydantic(elements)
      else
        raise Error, "Unknown format: #{format}"
      end
    end

    private

    def render_raw(elements)
      content = elements.map { |element| Components.render_element(element, @context) }.join('')
      
      # For raw format, wrap in message boundaries like Python package does
      if @context.chat && !content.strip.empty?
        # Determine if this should be system or human message
        # If it contains role/task/instructions, it's typically a system message
        # Otherwise, it's a human message
        message_type = determine_message_type(elements)
        "===== #{message_type} =====\n\n#{content.strip}\n"
      else
        content
      end
    end

    def render_dict(elements)
      # Render content first to allow meta components to modify context
      content = render_raw(elements)
      
      # Gather metadata after rendering
      metadata = {
        'chat' => @context.chat,
        'stylesheet' => @context.stylesheet,
        'variables' => @context.variables
      }
      
      # Include custom metadata (title, description, etc.)
      metadata.merge!(@context.custom_metadata) if @context.custom_metadata && !@context.custom_metadata.empty?
      
      # Include additional metadata if present
      metadata['response_schema'] = @context.response_schema if @context.response_schema
      metadata['tools'] = @context.tools if @context.tools && !@context.tools.empty?
      metadata['runtime_parameters'] = @context.runtime_parameters if @context.runtime_parameters && !@context.runtime_parameters.empty?
      
      {
        'content' => content,
        'metadata' => metadata
      }
    end

    def render_openai_chat(elements)
      # First render to collect structured messages
      content = render_raw(elements)
      
      # Use structured messages if available
      if @context.respond_to?(:chat_messages) && !@context.chat_messages.empty?
        @context.chat_messages
      elsif @context.chat
        parse_chat_messages(content)
      else
        [{ 'role' => 'user', 'content' => content }]
      end
    end

    def render_langchain(elements)
      content = render_raw(elements)
      {
        'messages' => render_openai_chat(elements),
        'content' => content
      }
    end

    def render_pydantic(elements)
      # Simplified pydantic-like structure
      {
        'prompt' => render_raw(elements),
        'variables' => @context.variables,
        'chat_enabled' => @context.chat
      }
    end

    def parse_chat_messages(content)
      # Simplified chat message parsing
      # In a full implementation, this would be more sophisticated
      messages = []
      current_role = 'user'
      current_content = ''

      content.split(/\n\n+/).each do |section|
        section = section.strip
        next if section.empty?

        # Simple heuristic: if section starts with certain patterns, it might be assistant content
        if section.start_with?('**Output:**', '**Assistant:**', 'Response:')
          if !current_content.empty?
            messages << { 'role' => current_role, 'content' => current_content.strip }
          end
          current_role = 'assistant'
          current_content = section.gsub(/^\*\*(Output|Assistant):\*\*\s*/, '').gsub(/^Response:\s*/, '')
        else
          current_content += (current_content.empty? ? '' : "\n\n") + section
        end
      end

      if !current_content.empty?
        messages << { 'role' => current_role, 'content' => current_content.strip }
      end

      messages.empty? ? [{ 'role' => 'user', 'content' => content }] : messages
    end

    def determine_message_type(elements)
      # Extract tag names from elements
      tag_names = elements.map(&:tag_name).compact
      
      # Check for system-oriented components
      has_role = tag_names.include?(:role)
      has_task = tag_names.include?(:task)
      has_hint = tag_names.include?(:hint)
      
      # Check for human-oriented components or content that suggests user interaction
      has_document = tag_names.include?(:document) || tag_names.include?('Document')
      has_question_content = elements.any? { |el| 
        el.respond_to?(:content) && el.content&.match?(/\b(what|how|why|when|where|please|can you)\b/i)
      }
      
      # System message detection rules based on original TypeScript implementation:
      # 1. If it's only role/task/hint components → system message
      # 2. If it has role AND task → system message (instruction setup)
      # 3. If it has role but also user interaction content → human message
      # 4. If it has document import or question-like content → human message
      
      if has_role && has_task
        # Role + Task = system instruction setup
        'system'
      elsif has_role && !has_document && !has_question_content && tag_names.all? { |tag| [:role, :task, :hint, :text, :p].include?(tag) }
        # Pure role/task/hint setup without user content
        'system'
      elsif has_document || has_question_content
        # Document import or question-like content = human message
        'human'
      else
        # Default to human for mixed or ambiguous content
        'human'
      end
    end
  end
end
