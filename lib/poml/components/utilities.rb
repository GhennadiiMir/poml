module Poml
  # AI Message component for wrapping AI responses
  class AiMessageComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      
      # Add to structured chat messages if context supports it
      if @context.respond_to?(:chat_messages)
        @context.chat_messages << {
          'role' => 'assistant',
          'content' => content
        }
        # Return empty for raw format to avoid duplication
        return ''
      end
      
      if xml_mode?
        render_as_xml('ai-msg', content, { speaker: 'ai' })
      else
        content
      end
    end
  end

  # Human Message component for wrapping user messages
  class HumanMessageComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      
      # Add to structured chat messages if context supports it
      if @context.respond_to?(:chat_messages)
        @context.chat_messages << {
          'role' => 'user',
          'content' => content
        }
        # Return empty for raw format to avoid duplication
        return ''
      end
      
      if xml_mode?
        render_as_xml('user-msg', content, { speaker: 'human' })
      else
        content
      end
    end
  end

  # System Message component for wrapping system messages
  class SystemMessageComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      
      # Add to structured chat messages if context supports it
      if @context.respond_to?(:chat_messages)
        @context.chat_messages << {
          'role' => 'system',
          'content' => content
        }
        # Return empty for raw format to avoid duplication
        return ''
      end
      
      if xml_mode?
        render_as_xml('system-msg', content, { speaker: 'system' })
      else
        content
      end
    end
  end

  # Message Content component for displaying message content
  class MessageContentComponent < Component
    def render
      apply_stylesheet
      
      content_attr = get_attribute('content')
      
      if content_attr.is_a?(Array)
        # Handle array of content items
        content_attr.map { |item| 
          item.is_a?(String) ? item : item.to_s 
        }.join('')
      elsif content_attr.is_a?(String)
        content_attr
      else
        content_attr.to_s
      end
    end
  end

  # Conversation component for displaying chat conversations
  class ConversationComponent < Component
    def render
      apply_stylesheet
      
      messages_attr = get_attribute('messages')
      messages = if messages_attr.is_a?(String)
        begin
          require 'json'
          JSON.parse(messages_attr)
        rescue JSON::ParserError
          []
        end
      else
        messages_attr || []
      end
      
      selected_messages = get_attribute('selectedMessages')
      
      # Apply message selection if specified
      if selected_messages
        messages = apply_message_selection(messages, selected_messages)
      end
      
      if xml_mode?
        render_conversation_xml(messages)
      else
        render_conversation_markdown(messages)
      end
    end
    
    private
    
    def apply_message_selection(messages, selection)
      return messages unless selection
      
      if selection.include?(':')
        # Handle slice notation like "2:4" or "-6:"
        start_idx, end_idx = parse_slice(selection, messages.length)
        messages[start_idx...end_idx] || []
      elsif selection.is_a?(Integer)
        # Single message index
        [messages[selection]].compact
      else
        messages
      end
    end
    
    def parse_slice(slice_str, total_length)
      if slice_str.start_with?('-') && slice_str.end_with?(':')
        # Handle "-6:" (last 6 messages)
        count = slice_str[1..-2].to_i
        [total_length - count, total_length]
      elsif slice_str.include?(':')
        parts = slice_str.split(':')
        start_idx = parts[0].empty? ? 0 : parts[0].to_i
        end_idx = parts[1].empty? ? total_length : parts[1].to_i
        [start_idx, end_idx]
      else
        index = slice_str.to_i
        [index, index + 1]
      end
    end
    
    def render_conversation_xml(messages)
      result = ['<conversation>']
      messages.each do |msg|
        speaker = msg['speaker'] || 'human'
        content = msg['content'] || ''
        result << "  <msg speaker=\"#{speaker}\">#{escape_xml(content)}</msg>"
      end
      result << '</conversation>'
      result.join("\n")
    end
    
    def render_conversation_markdown(messages)
      result = []
      messages.each do |msg|
        speaker = msg['speaker'] || 'human'
        content = msg['content'] || ''
        
        case speaker.downcase
        when 'human', 'user'
          result << "**Human:** #{content}"
        when 'ai', 'assistant'
          result << "**Assistant:** #{content}"
        when 'system'
          result << "**System:** #{content}"
        else
          result << "**#{speaker.capitalize}:** #{content}"
        end
        result << ""
      end
      result.join("\n")
    end
    
    def escape_xml(text)
      text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
    end
  end

  # Folder component for displaying directory structures
  class FolderComponent < Component
    require 'find'
    
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      filter = get_attribute('filter')
      max_depth = get_attribute('maxDepth', 3).to_i
      show_content = get_attribute('showContent', false)
      syntax = get_attribute('syntax', 'text')
      
      return '[Folder: no src specified]' unless src
      return '[Folder: directory not found]' unless Dir.exist?(src)
      
      tree_data = build_tree_structure(src, filter, max_depth, show_content)
      
      if xml_mode?
        render_folder_xml(tree_data)
      else
        case syntax
        when 'markdown'
          render_folder_markdown(tree_data)
        when 'json'
          require 'json'
          JSON.pretty_generate(tree_data)
        else
          render_folder_text(tree_data)
        end
      end
    end
    
    private
    
    def build_tree_structure(path, filter, max_depth, show_content, current_depth = 0)
      return nil if current_depth >= max_depth
      
      items = []
      
      begin
        Dir.entries(path).sort.each do |entry|
          next if entry.start_with?('.')
          
          full_path = File.join(path, entry)
          
          if File.directory?(full_path)
            # Check if directory should be included
            if !filter || entry.match?(Regexp.new(filter))
              sub_items = build_tree_structure(full_path, filter, max_depth, show_content, current_depth + 1)
              if sub_items && !sub_items.empty?
                items << {
                  name: "#{entry}/",
                  type: 'directory',
                  children: sub_items
                }
              end
            end
          else
            # Check if file should be included
            if !filter || entry.match?(Regexp.new(filter))
              item = {
                name: entry,
                type: 'file'
              }
              
              if show_content
                begin
                  content = File.read(full_path, encoding: 'utf-8')
                  item[:content] = content
                rescue
                  item[:content] = '[Binary file or read error]'
                end
              end
              
              items << item
            end
          end
        end
      rescue => e
        return [{ name: "[Error: #{e.message}]", type: 'error' }]
      end
      
      items
    end
    
    def render_folder_text(items, indent = 0)
      result = []
      prefix = '  ' * indent
      
      items.each do |item|
        result << "#{prefix}#{item[:name]}"
        
        if item[:content]
          content_lines = item[:content].split("\n")
          content_lines.each do |line|
            result << "#{prefix}  #{line}"
          end
          result << ""
        end
        
        if item[:children]
          result << render_folder_text(item[:children], indent + 1)
        end
      end
      
      result.join("\n")
    end
    
    def render_folder_markdown(items, indent = 0)
      result = []
      prefix = '  ' * indent
      
      items.each do |item|
        if item[:type] == 'directory'
          result << "#{prefix}- **#{item[:name]}**"
        else
          result << "#{prefix}- #{item[:name]}"
        end
        
        if item[:content]
          result << "#{prefix}  ```"
          item[:content].split("\n").each do |line|
            result << "#{prefix}  #{line}"
          end
          result << "#{prefix}  ```"
          result << ""
        end
        
        if item[:children]
          result << render_folder_markdown(item[:children], indent + 1)
        end
      end
      
      result.join("\n")
    end
    
    def render_folder_xml(items)
      result = ['<folder>']
      items.each do |item|
        if item[:type] == 'directory'
          result << "  <directory name=\"#{escape_xml(item[:name])}\">"
          if item[:children]
            render_folder_xml_items(item[:children], result, 2)
          end
          result << "  </directory>"
        else
          if item[:content]
            result << "  <file name=\"#{escape_xml(item[:name])}\">"
            result << "    <content>#{escape_xml(item[:content])}</content>"
            result << "  </file>"
          else
            result << "  <file name=\"#{escape_xml(item[:name])}\"/>"
          end
        end
      end
      result << '</folder>'
      result.join("\n")
    end
    
    def render_folder_xml_items(items, result, indent_level)
      indent = '  ' * indent_level
      items.each do |item|
        if item[:type] == 'directory'
          result << "#{indent}<directory name=\"#{escape_xml(item[:name])}\">"
          if item[:children]
            render_folder_xml_items(item[:children], result, indent_level + 1)
          end
          result << "#{indent}</directory>"
        else
          if item[:content]
            result << "#{indent}<file name=\"#{escape_xml(item[:name])}\">"
            result << "#{indent}  <content>#{escape_xml(item[:content])}</content>"
            result << "#{indent}</file>"
          else
            result << "#{indent}<file name=\"#{escape_xml(item[:name])}\"/>"
          end
        end
      end
    end
    
    def escape_xml(text)
      text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
    end
  end

  # Tree component for rendering tree structures
  class TreeComponent < Component
    def render
      apply_stylesheet
      
      items_attr = get_attribute('items')
      items = if items_attr.is_a?(String)
        begin
          require 'json'
          JSON.parse(items_attr)
        rescue JSON::ParserError
          []
        end
      else
        items_attr || []
      end
      
      show_content = get_attribute('showContent', false)
      syntax = get_attribute('syntax', 'text')
      
      if xml_mode?
        render_tree_xml(items, show_content)
      else
        case syntax
        when 'markdown'
          render_tree_markdown(items, show_content)
        when 'json'
          require 'json'
          JSON.pretty_generate(items)
        else
          render_tree_text(items, show_content)
        end
      end
    end
    
    private
    
    def render_tree_text(items, show_content, indent = 0)
      result = []
      prefix = '  ' * indent
      
      items.each do |item|
        result << "#{prefix}#{item['name'] || item[:name]}"
        
        if show_content && (item['content'] || item[:content])
          content = item['content'] || item[:content]
          content.to_s.split("\n").each do |line|
            result << "#{prefix}  #{line}"
          end
        end
        
        children = item['children'] || item[:children]
        if children && !children.empty?
          result << render_tree_text(children, show_content, indent + 1)
        end
      end
      
      result.join("\n")
    end
    
    def render_tree_markdown(items, show_content, indent = 0)
      result = []
      prefix = '  ' * indent
      
      items.each do |item|
        name = item['name'] || item[:name]
        result << "#{prefix}- #{name}"
        
        if show_content && (item['content'] || item[:content])
          content = item['content'] || item[:content]
          result << "#{prefix}  ```"
          content.to_s.split("\n").each do |line|
            result << "#{prefix}  #{line}"
          end
          result << "#{prefix}  ```"
        end
        
        children = item['children'] || item[:children]
        if children && !children.empty?
          result << render_tree_markdown(children, show_content, indent + 1)
        end
      end
      
      result.join("\n")
    end
    
    def render_tree_xml(items, show_content, indent_level = 1)
      result = ['<tree>']
      render_tree_xml_items(items, result, show_content, indent_level)
      result << '</tree>'
      result.join("\n")
    end
    
    def render_tree_xml_items(items, result, show_content, indent_level)
      indent = '  ' * indent_level
      
      items.each do |item|
        name = item['name'] || item[:name]
        children = item['children'] || item[:children]
        content = item['content'] || item[:content] if show_content
        
        if children && !children.empty?
          result << "#{indent}<item name=\"#{escape_xml(name)}\">"
          if content
            result << "#{indent}  <content>#{escape_xml(content)}</content>"
          end
          render_tree_xml_items(children, result, show_content, indent_level + 1)
          result << "#{indent}</item>"
        else
          if content
            result << "#{indent}<item name=\"#{escape_xml(name)}\">"
            result << "#{indent}  <content>#{escape_xml(content)}</content>"
            result << "#{indent}</item>"
          else
            result << "#{indent}<item name=\"#{escape_xml(name)}\"/>"
          end
        end
      end
    end
    
    def escape_xml(text)
      text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
    end
  end
end
