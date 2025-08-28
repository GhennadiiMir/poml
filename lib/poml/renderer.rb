require 'json'

module Poml
  # Renderer converts parsed POML elements to various output formats
  class Renderer
    def initialize(context)
      @context = context
    end

    def render(elements, format = 'dict')
      # Set the output format in context so components can adjust behavior
      @context.output_format = format
      
      case format
      when 'raw'
        render_raw(elements)
      when 'dict'
        render_dict(elements)
      when 'openai_chat'
        render_openai_chat(elements)
      when 'openaiResponse'
        render_openai_response(elements)
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

    def render_openai_response(elements)
      # OpenAI Response format - standardized AI response structure
      # Different from openai_chat which focuses on conversation messages
      content = render_raw(elements)
      
      response = {
        'content' => content.strip,
        'type' => 'assistant'
      }
      
      # Include metadata if available
      metadata = {}
      metadata['variables'] = @context.variables if @context.variables && !@context.variables.empty?
      metadata['response_schema'] = @context.response_schema if @context.response_schema
      metadata['tools'] = @context.tools if @context.tools && !@context.tools.empty?
      metadata['runtime_parameters'] = @context.runtime_parameters if @context.runtime_parameters && !@context.runtime_parameters.empty?
      
      # Include custom metadata (title, description, etc.)
      metadata.merge!(@context.custom_metadata) if @context.custom_metadata && !@context.custom_metadata.empty?
      
      response['metadata'] = metadata unless metadata.empty?
      
      response
    end

    def render_langchain(elements)
      content = render_raw(elements)
      {
        'messages' => render_openai_chat(elements),
        'content' => content
      }
    end

    def render_pydantic(elements)
      # Enhanced pydantic format with Python interoperability features
      raw_content = render_raw(elements)
      
      # Enhanced Pydantic-compatible structure
      pydantic_output = {
        'content' => raw_content,
        'variables' => @context.variables || {},
        'chat_enabled' => @context.chat,
        'metadata' => {
          'format' => 'pydantic',
          'version' => '1.0',
          'python_compatible' => true,
          'strict_json_schema' => true
        }
      }
      
      # Add response schema if available (from output-schema components)
      if @context.response_schema
        pydantic_output['schemas'] = [make_schema_strict(@context.response_schema)]
      else
        pydantic_output['schemas'] = []
      end
      
      # Add tools if available (from tool-definition components)
      if @context.tools && !@context.tools.empty?
        pydantic_output['tools'] = @context.tools.map { |tool| format_tool_for_pydantic(tool) }
      else
        pydantic_output['tools'] = []
      end
      
      # Add custom metadata if available (from meta components)
      if @context.custom_metadata && !@context.custom_metadata.empty?
        pydantic_output['custom_metadata'] = @context.custom_metadata
      else
        pydantic_output['custom_metadata'] = {}
      end
      
      pydantic_output
    end
    
    private
    
    def make_schema_strict(schema)
      # Convert schema to strict JSON schema format (Pydantic compatible)
      return schema unless schema.is_a?(Hash)
      
      strict_schema = schema.dup
      
      if strict_schema['type'] == 'object'
        strict_schema['additionalProperties'] = false
        
        # Make all properties required if not specified
        if strict_schema['properties'] && !strict_schema['required']
          strict_schema['required'] = strict_schema['properties'].keys
        end
        
        # Recursively process nested objects
        if strict_schema['properties']
          strict_schema['properties'] = strict_schema['properties'].transform_values do |prop|
            make_schema_strict(prop)
          end
        end
      elsif strict_schema['type'] == 'array' && strict_schema['items']
        strict_schema['items'] = make_schema_strict(strict_schema['items'])
      end
      
      # Remove null defaults for strict compatibility
      strict_schema.delete('default') if strict_schema['default'].nil?
      
      strict_schema
    end
    
    def format_tool_for_pydantic(tool)
      # Format tool definition for Pydantic compatibility
      formatted_tool = {
        'name' => tool['name'],
        'description' => tool['description']
      }
      
      if tool['parameters']
        # Convert parameters to Pydantic-compatible format
        formatted_tool['parameters'] = make_schema_strict(tool['parameters'])
      end
      
      formatted_tool
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
      _has_hint = tag_names.include?(:hint)  # Prefix with underscore to indicate intentionally unused
      
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
