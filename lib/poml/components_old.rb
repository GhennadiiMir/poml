module Poml
  # Base class for all POML components
  class Component
    attr_reader :element, :context

    def initialize(element, context)
      @element = element
      @context = context
    end

    def render
      raise NotImplementedError, "Components must implement render method"
    end

    protected

    def apply_stylesheet
      # Apply stylesheet rules to the element
      style_rules = @context.stylesheet[@element.tag_name.to_s] || {}
      style_rules.each do |attr, value|
        @element.attributes[attr] ||= value
      end

      # Apply class-based styles
      class_name = @element.attributes['classname'] || @element.attributes['className']
      if class_name
        class_rules = @context.stylesheet[".#{class_name}"] || {}
        class_rules.each do |attr, value|
          @element.attributes[attr] ||= value
        end
      end
    end

    def xml_mode?
      @context.determine_syntax(@element) == 'xml'
    end

    def render_as_xml(tag_name, content = nil, attributes = {})
      # Render as XML element with proper formatting
      content ||= render_children
      attrs_str = attributes.map { |k, v| " #{k}=\"#{v}\"" }.join('')
      
      if content.strip.empty?
        "<#{tag_name}#{attrs_str}/>\n"
      else
        # Add line breaks for nice formatting
        if content.include?('<item>')
          # Multi-line content with nested items - add indentation
          indented_content = content.split("\n").map { |line| 
            line.strip.empty? ? "" : "  #{line}" 
          }.join("\n").strip
          "<#{tag_name}#{attrs_str}>\n  #{indented_content}\n</#{tag_name}>\n"
        else
          # Simple content
          "<#{tag_name}#{attrs_str}>#{content}</#{tag_name}>\n"
        end
      end
    end

    def get_attribute(name, default = nil)
      value = @element.attributes[name.to_s.downcase]
      case value
      when REXML::Attribute
        value.value
      when String
        value
      else
        default
      end
    end

    def render_children
      return '' if @element.children.empty?
      
      rendered_children = @element.children.map do |child_element|
        Components.render_element(child_element, @context)
      end
      
      # Add proper spacing between elements - specifically between text and components
      result = []
      rendered_children.each_with_index do |child_content, index|
        result << child_content
        
        # Add spacing if current element is text and next element is a component  
        if index < rendered_children.length - 1
          current_element = @element.children[index]
          next_element = @element.children[index + 1]
          
          if current_element.text? && next_element.component?
            result << "\n\n"
          end
        end
      end
      
      result.join('')
    end
    
    def apply_text_transform(text)
      return text if text.nil? || text.empty?
      
      # Get text transformation from stylesheet
      component_name = self.class.name.split('::').last.gsub('Component', '').downcase
      
      # Check for text transformation in stylesheet - first try component-specific, then "cp" (for captioned paragraph inheritance)
      transform = @context.stylesheet.dig(component_name, 'captionTextTransform') ||
                  @context.stylesheet.dig('cp', 'captionTextTransform')
      
      case transform
      when 'upper'
        text.upcase
      when 'lower'
        text.downcase
      when 'capitalize'
        text.split(' ').map(&:capitalize).join(' ')
      else
        text
      end
    end
  end

  # Text component for plain text content
  class TextComponent < Component
    def render
      @element.content
    end
  end

  # Role component
  class RoleComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content

      if xml_mode?
        render_as_xml('role', content)
      else
        caption = apply_text_transform(get_attribute('caption', 'Role'))
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

  # Task component
  class TaskComponent < Component
    def render
      apply_stylesheet
      
      # For mixed content (text + elements), preserve spacing
      content = if @element.children.empty?
        @element.content.strip
      else
        # Don't strip when there are children to preserve spacing between text and elements
        render_children
      end

      if xml_mode?
        render_as_xml('task', content)
      else
        caption = apply_text_transform(get_attribute('caption', 'Task'))
        caption_style = get_attribute('captionStyle', 'header')

        case caption_style
        when 'header'
          # Don't add extra newlines if content already ends with newlines
          content_ending = content.end_with?("\n\n") ? "" : "\n\n"
          "# #{caption}\n\n#{content}#{content_ending}"
        when 'bold'
          "**#{caption}:** #{content}\n\n"
        when 'plain'
          "#{caption}: #{content}\n\n"
        when 'hidden'
          content_ending = content.end_with?("\n\n") ? "" : "\n\n"
          "#{content}#{content_ending}"
        else
          content_ending = content.end_with?("\n\n") ? "" : "\n\n"
          "# #{caption}\n\n#{content}#{content_ending}"
        end
      end
    end
  end

  # Hint component
  class HintComponent < Component
    def render
      apply_stylesheet
      
      caption = get_attribute('caption', 'Hint')
      caption_style = get_attribute('captionStyle', 'header')
      content = @element.content.empty? ? render_children : @element.content

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

  # Document component (reads and includes external files)
  class DocumentComponent < Component
    def initialize(element, context)
      super
      @src = element.attributes['src']
      @selected_pages = element.attributes['selectedpages'] || element.attributes['selectedPages']
      @syntax = element.attributes['syntax'] || 'text'
    end

    def render(context = nil)
      return "[Document: no src specified]" unless @src

      begin
        # Resolve file path - try relative to current working directory first
        file_path = @src
        unless File.exist?(file_path)
          # Try relative to examples directory
          examples_dir = File.expand_path('examples')
          file_path = File.join(examples_dir, @src)
        end
        
        unless File.exist?(file_path)
          # Try relative to project root examples directory  
          project_root = File.expand_path('..', File.dirname(__dir__))
          examples_dir = File.join(project_root, 'examples')
          file_path = File.join(examples_dir, @src)
        end
        
        # Check if file exists
        unless File.exist?(file_path)
          return "[Document: #{@src} (not found)]"
        end

        # Check file type and extract content
        if file_path.downcase.end_with?('.pdf')
          read_pdf_content(file_path)
        else
          File.read(file_path)
        end
      rescue => e
        "[Document: #{@src} (error reading: #{e.message})]"
      end
    end

    private

    def read_pdf_content(file_path)
      if @selected_pages
        # Parse Python-style slice notation
        start_page, end_page = parse_python_style_slice(@selected_pages, get_pdf_page_count(file_path))
        
        # Convert 0-indexed to 1-indexed for pdftotext (-f and -l are 1-indexed)
        start_page_1indexed = start_page + 1
        # For Python slice "1:3" -> start=1, end=3 (0-indexed, end exclusive)
        # This means we want pages 1,2 (0-indexed) = pages 2,3 (1-indexed)
        # So pdftotext should use -f 2 -l 3
        last_page_1indexed = start_page_1indexed + (end_page - start_page) - 1
        
        if end_page > start_page + 1
          # Extract range of pages
          command = "pdftotext -f #{start_page_1indexed} -l #{last_page_1indexed} \"#{file_path}\" -"
          result = `#{command}`
        else
          # Single page
          command = "pdftotext -f #{start_page_1indexed} -l #{start_page_1indexed} \"#{file_path}\" -"
          result = `#{command}`
        end
      else
        # Extract all pages
        result = `pdftotext "#{file_path}" -`
      end
      
      if $?.success?
        result
      else
        "[Document: #{@src} (error extracting PDF)]"
      end
    end

    def parse_python_style_slice(slice, total_length)
      # Handle different slice formats: "1:3", ":3", "3:", "3", ":"
      if slice == ':'
        [0, total_length]
      elsif slice.end_with?(':')
        [slice[0..-2].to_i, total_length]
      elsif slice.start_with?(':')
        [0, slice[1..-1].to_i]
      elsif slice.include?(':')
        parts = slice.split(':')
        [parts[0].to_i, parts[1].to_i]
      else
        index = slice.to_i
        [index, index + 1]
      end
    end

    def get_pdf_page_count(file_path)
      # Get page count using pdfinfo (if available) or default to large number
      result = `pdfinfo "#{file_path}" 2>/dev/null | grep "Pages:" | awk '{print $2}'`
      if $?.success? && !result.strip.empty?
        result.strip.to_i
      else
        # Fallback: try to extract and count pages
        100  # Default fallback
      end
    end
  end

  # Table component for displaying tabular data
  class TableComponent < Component
    require 'csv'
    require 'json'
    
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      records_attr = get_attribute('records')
      columns_attr = get_attribute('columns') 
      parser = get_attribute('parser', 'auto')
      syntax = get_attribute('syntax')
      selected_columns = get_attribute('selectedColumns')
      selected_records = get_attribute('selectedRecords')
      max_records = get_attribute('maxRecords')
      max_columns = get_attribute('maxColumns')
      
      # Load data from source or use provided records
      data = if src
        load_table_data(src, parser)
      elsif records_attr
        parse_records_attribute(records_attr)
      else
        { records: [], columns: [] }
      end
      
      # Apply column and record selection
      data = apply_selection(data, selected_columns, selected_records, max_records, max_columns)
      
      # Check syntax preference
      if syntax == 'tsv' || syntax == 'csv'
        render_table_raw(data, syntax)
      elsif xml_mode?
        render_table_xml(data)
      else
        render_table_markdown(data)
      end
    end
    
    private
    
    def load_table_data(src, parser)
      # Resolve relative paths
      file_path = if src.start_with?('/')
        src
      else
        base_path = if @context.source_path
          File.dirname(@context.source_path)
        else
          Dir.pwd
        end
        File.join(base_path, src)
      end
      
      unless File.exist?(file_path)
        return { records: [], columns: [] }
      end
      
      # Determine parser from file extension if auto
      if parser == 'auto'
        ext = File.extname(file_path).downcase
        parser = case ext
        when '.csv' then 'csv'
        when '.tsv' then 'tsv'
        when '.json' then 'json'
        when '.jsonl' then 'jsonl'
        else 'csv'
        end
      end
      
      case parser
      when 'csv'
        parse_csv_file(file_path)
      when 'tsv'
        parse_tsv_file(file_path)
      when 'json'
        parse_json_file(file_path)
      when 'jsonl'
        parse_jsonl_file(file_path)
      else
        { records: [], columns: [] }
      end
    rescue => e
      { records: [], columns: [] }
    end
    
    def parse_csv_file(file_path)
      data = CSV.read(file_path, headers: true)
      columns = data.headers.map { |header| { field: header, header: header } }
      records = data.map(&:to_h)
      { records: records, columns: columns }
    end
    
    def parse_tsv_file(file_path)
      data = CSV.read(file_path, headers: true, col_sep: "\t")
      columns = data.headers.map { |header| { field: header, header: header } }
      records = data.map(&:to_h)
      { records: records, columns: columns }
    end
    
    def parse_json_file(file_path)
      content = File.read(file_path)
      records = JSON.parse(content)
      
      # Extract columns from first record if it's an array of objects
      columns = if records.is_a?(Array) && !records.empty? && records.first.is_a?(Hash)
        records.first.keys.map { |key| { field: key, header: key } }
      else
        []
      end
      
      { records: records.is_a?(Array) ? records : [records], columns: columns }
    end
    
    def parse_jsonl_file(file_path)
      records = []
      File.readlines(file_path).each do |line|
        records << JSON.parse(line.strip) unless line.strip.empty?
      end
      
      # Extract columns from first record
      columns = if !records.empty? && records.first.is_a?(Hash)
        records.first.keys.map { |key| { field: key, header: key } }
      else
        []
      end
      
      { records: records, columns: columns }
    end
    
    def parse_records_attribute(records_attr)
      # Handle string records (JSON) or already parsed arrays
      records = if records_attr.is_a?(String)
        JSON.parse(records_attr)
      else
        records_attr
      end
      
      columns = if records.is_a?(Array) && !records.empty? && records.first.is_a?(Hash)
        records.first.keys.map { |key| { field: key, header: key } }
      else
        []
      end
      
      { records: records.is_a?(Array) ? records : [records], columns: columns }
    end
    
    def apply_selection(data, selected_columns, selected_records, max_records, max_columns)
      records = data[:records]
      columns = data[:columns]
      
      # Apply column selection
      if selected_columns && columns
        if selected_columns.is_a?(Array)
          # Array of column names
          new_columns = selected_columns.map do |col_name|
            columns.find { |col| col[:field] == col_name } || { field: col_name, header: col_name }
          end
          columns = new_columns
          records = records.map do |record|
            selected_columns.each_with_object({}) { |col, new_record| new_record[col] = record[col] }
          end
        elsif selected_columns.is_a?(String) && selected_columns.include?(':')
          # Python-style slice
          start_idx, end_idx = parse_slice(selected_columns, columns.length)
          columns = columns[start_idx...end_idx]
          column_fields = columns.map { |col| col[:field] }
          records = records.map do |record|
            column_fields.each_with_object({}) { |field, new_record| new_record[field] = record[field] }
          end
        end
      end
      
      # Apply record selection
      if selected_records
        if selected_records.is_a?(Array)
          records = selected_records.map { |idx| records[idx] }.compact
        elsif selected_records.is_a?(String) && selected_records.include?(':')
          start_idx, end_idx = parse_slice(selected_records, records.length)
          records = records[start_idx...end_idx]
        end
      end
      
      # Apply max records
      if max_records && records.length > max_records
        # Show top half and bottom half with ellipsis
        top_rows = (max_records / 2.0).ceil
        bottom_rows = max_records - top_rows
        ellipsis_record = columns.each_with_object({}) { |col, record| record[col[:field]] = '...' }
        records = records[0...top_rows] + [ellipsis_record] + records[-bottom_rows..-1]
      end
      
      # Apply max columns
      if max_columns && columns && columns.length > max_columns
        columns = columns[0...max_columns]
        column_fields = columns.map { |col| col[:field] }
        records = records.map do |record|
          column_fields.each_with_object({}) { |field, new_record| new_record[field] = record[field] }
        end
      end
      
      { records: records, columns: columns }
    end
    
    def parse_slice(slice_str, total_length)
      # Parse Python-style slice notation like "1:3"
      parts = slice_str.split(':')
      start_idx = parts[0].to_i
      end_idx = parts[1] ? parts[1].to_i : total_length
      [start_idx, end_idx]
    end
    
    def render_table_markdown(data)
      records = data[:records]
      columns = data[:columns]
      
      return '' if records.empty?
      
      # If no columns specified, infer from first record
      if columns.empty? && records.first.is_a?(Hash)
        columns = records.first.keys.map { |key| { field: key, header: key } }
      end
      
      return '' if columns.empty?
      
      # Build markdown table
      result = []
      
      # Header row
      headers = columns.map { |col| col[:header] || col[:field] }
      result << "| #{headers.join(' | ')} |"
      
      # Separator row
      result << "| #{headers.map { '---' }.join(' | ')} |"
      
      # Data rows
      records.each do |record|
        row_values = columns.map do |col|
          value = record[col[:field]]
          value.nil? ? '' : value.to_s
        end
        result << "| #{row_values.join(' | ')} |"
      end
      
      result.join("\n")
    end
    
    def render_table_raw(data, syntax)
      records = data[:records]
      columns = data[:columns]
      
      return '' if records.empty?
      
      # If no columns specified, infer from first record
      if columns.empty? && records.first.is_a?(Hash)
        columns = records.first.keys.map { |key| { field: key, header: key } }
      end
      
      return '' if columns.empty?
      
      # Determine separator
      separator = syntax == 'tsv' ? "\t" : ","
      
      # Build raw table
      result = []
      
      # Header row
      headers = columns.map { |col| col[:header] || col[:field] }
      result << headers.join(separator)
      
      # Data rows
      records.each do |record|
        row_values = columns.map do |col|
          value = record[col[:field]]
          value.nil? ? '' : value.to_s
        end
        result << row_values.join(separator)
      end
      
      result.join("\n")
    end
    
    def render_table_xml(data)
      records = data[:records]
      columns = data[:columns]
      
      return '' if records.empty?
      
      # If no columns specified, infer from first record
      if columns.empty? && records.first.is_a?(Hash)
        columns = records.first.keys.map { |key| { field: key, header: key } }
      end
      
      return '' if columns.empty?
      
      # Build XML table structure
      result = []
      result << '<table>'
      result << '  <thead>'
      result << '    <trow>'
      columns.each do |col|
        result << "      <tcell>#{escape_xml(col[:header] || col[:field])}</tcell>"
      end
      result << '    </trow>'
      result << '  </thead>'
      result << '  <tbody>'
      
      records.each do |record|
        result << '    <trow>'
        columns.each do |col|
          value = record[col[:field]]
          result << "      <tcell>#{escape_xml(value.nil? ? '' : value.to_s)}</tcell>"
        end
        result << '    </trow>'
      end
      
      result << '  </tbody>'
      result << '</table>'
      
      result.join("\n")
    end
    
    def escape_xml(text)
      text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
    end
  end

  # Image component
  class ImageComponent < Component
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      alt = get_attribute('alt', '')
      syntax = get_attribute('syntax', 'text')

      if syntax == 'multimedia'
        "[Image: #{src}]#{alt.empty? ? '' : " (#{alt})"}"
      else
        alt.empty? ? "[Image: #{src}]" : alt
      end
    end
  end

  # Paragraph component
  class ParagraphComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      "#{content}\n\n"
    end
  end

  # Example component
  class ExampleComponent < Component
    def render
      apply_stylesheet
      
      content = render_children
      if @context.chat
        content
      else
        "## Example\n\n#{content}\n\n"
      end
    end
  end

  # Input component
  class InputComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      if @context.chat
        content
      else
        "**Input:** #{content}\n\n"
      end
    end
  end

  # Output component
  class OutputComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      if @context.chat
        content
      else
        "**Output:** #{content}\n\n"
      end
    end
  end

  # Output format component
  class OutputFormatComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content

      if xml_mode?
        render_as_xml('outputFormat', content)
      else
        caption = get_attribute('caption', 'Output Format')
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

  # List component
  class ListComponent < Component
    def render
      apply_stylesheet
      
      if xml_mode?
        # In XML mode, lists don't exist - items are rendered directly
        @element.children.map do |child|
          if child.tag_name == :item
            Components.render_element(child, @context)
          end
        end.compact.join('')
      else
        list_style = get_attribute('listStyle', 'dash')
        items = []
        index = 0
        
        @element.children.each do |child|
          if child.tag_name == :item
            index += 1
            
            bullet = case list_style
            when 'decimal', 'number', 'numbered'
              "#{index}. "
            when 'star'
              "* "
            when 'plus'
              "+ "
            when 'dash', 'bullet', 'unordered'
              "- "
            else
              "- "
            end
            
            # Get text content and nested elements separately
            text_content = child.content.strip
            nested_elements = child.children.reject { |c| c.tag_name == :text }
            
            if nested_elements.any?
              # Item has both text and nested elements (like nested lists)
              nested_content = nested_elements.map { |nested_child| 
                Components.render_element(nested_child, @context) 
              }.join('').strip
              
              # Format with text content on first line, nested content indented
              indented_nested = nested_content.split("\n").map { |line| 
                line.strip.empty? ? "" : "   #{line}" 
              }.join("\n").strip
              
              if text_content.empty?
                items << "#{bullet}#{indented_nested}"
              else
                items << "#{bullet}#{text_content} \n\n#{indented_nested}"
              end
            else
              # Simple text-only item
              items << "#{bullet}#{text_content}"
            end
          end
        end
        
        return "\n\n" if items.empty?
        items.join("\n") + "\n\n"
      end
    end
  end

  # Item component (for list items)
  class ItemComponent < Component
    def render
      apply_stylesheet
      content = @element.content.empty? ? render_children : @element.content.strip
      
      if xml_mode?
        "<item>#{content}</item>\n"
      else
        content
      end
    end
  end

  # CP component (custom component with caption)
  class CPComponent < Component
    def render
      apply_stylesheet
      
      caption = get_attribute('caption', '')
      caption_serialized = get_attribute('captionSerialized', caption)
      
      # Render children with increased header level for nested CPs
      content = if @element.content.empty?
        @context.with_increased_header_level { render_children }
      else
        @element.content
      end

      if xml_mode?
        # Use captionSerialized for XML tag name, fallback to caption
        tag_name = caption_serialized.empty? ? caption : caption_serialized
        return render_as_xml(tag_name, content) unless tag_name.empty?
        # If no caption, just return content
        return "#{content}\n\n"
      else
        caption_style = get_attribute('captionStyle', 'header')
        # Use captionSerialized for the actual header if provided
        display_caption = caption_serialized.empty? ? caption : caption_serialized
        
        # Apply stylesheet text transformation
        display_caption = apply_text_transform(display_caption)
        
        return content + "\n\n" if display_caption.empty?

        case caption_style
        when 'header'
          header_prefix = '#' * @context.header_level
          "#{header_prefix} #{display_caption}\n\n#{content}\n\n"
        when 'bold'
          "**#{display_caption}:** #{content}\n\n"
        when 'plain'
          "#{display_caption}: #{content}\n\n"
        when 'hidden'
          "#{content}\n\n"
        else
          header_prefix = '#' * @context.header_level
          "#{header_prefix} #{display_caption}\n\n#{content}\n\n"
        end
      end
    end
  end

  # StepwiseInstructions component
  class StepwiseInstructionsComponent < Component
    def render
      apply_stylesheet
      
      content = render_children

      if xml_mode?
        render_as_xml('stepwise-instructions', content)
      else
        caption = apply_text_transform(get_attribute('caption', 'Stepwise Instructions'))
        "# #{caption}\n\n#{content}\n\n"
      end
    end
  end

  # HumanMessage component
  class HumanMessageComponent < Component
    def render
      apply_stylesheet
      
      content = render_children

      if xml_mode?
        render_as_xml('human-message', content)
      else
        content
      end
    end
  end

  # QA component
  class QAComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content

      if xml_mode?
        render_as_xml('qa', content)
      else
        "**QUESTION:** #{content}\n\n**Answer:**\n\n"
      end
    end
  end

  # Let component (for template variables)
  class LetComponent < Component
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      name = get_attribute('name')
      
      if src && name
        # Load JSON file and set as template variable
        file_path = if src.start_with?('/')
          src
        else
          base_path = if @context.source_path
            File.dirname(@context.source_path)
          else
            Dir.pwd
          end
          File.join(base_path, src)
        end
        
        if File.exist?(file_path)
          begin
            content = File.read(file_path)
            data = JSON.parse(content)
            @context.variables[name] = data
          rescue => e
            # Silently fail for now
          end
        end
      end
      
      # Let components don't produce output
      ''
    end
  end

  # Enhanced Paragraph component with template support  
  class ParagraphComponent < Component
    def render
      apply_stylesheet
      
      # Handle template loops
      for_attr = get_attribute('for')
      if for_attr
        return render_template_loop(for_attr)
      end
      
      content = @element.content.empty? ? render_children : @element.content

      if xml_mode?
        render_as_xml('p', content)
      else
        "#{content}\n\n"
      end
    end
    
    private
    
    def render_template_loop(for_expr)
      # Parse for expression like "ins in instructions"
      if for_expr =~ /(\w+)\s+in\s+(\w+)/
        item_var = $1
        collection_var = $2
        
        collection = @context.variables[collection_var]
        return '' unless collection.is_a?(Array)
        
        results = []
        collection.each_with_index do |item, index|
          # Set template variables
          old_item = @context.variables[item_var]
          old_loop = @context.variables['loop']
          
          @context.variables[item_var] = item
          @context.variables['loop'] = { 'index' => index }
          
          # Render content with template substitution
          content = @element.content.empty? ? render_children : @element.content
          template_engine = TemplateEngine.new(@context)
          processed_content = template_engine.substitute(content)
          
          results << processed_content
          
          # Restore old variables
          if old_item
            @context.variables[item_var] = old_item
          else
            @context.variables.delete(item_var)
          end
          
          if old_loop
            @context.variables['loop'] = old_loop
          else
            @context.variables.delete('loop')
          end
        end
        
        results.join("\n")
      else
        # Invalid for expression, return empty
        ''
      end
    end
  end

  # Stylesheet component
  class StylesheetComponent < Component
    def render
      # Parse and apply stylesheet
      begin
        stylesheet_content = @element.content.strip
        if stylesheet_content.start_with?('{') && stylesheet_content.end_with?('}')
          stylesheet = JSON.parse(stylesheet_content)
          @context.stylesheet.merge!(stylesheet) if stylesheet.is_a?(Hash)
        end
      rescue => e
        # Silently fail JSON parsing errors
      end
      
      # Stylesheet components don't produce output
      ''
    end
  end

  # Component registry and factory
  module Components
    COMPONENT_MAPPING = {
      text: TextComponent,
      role: RoleComponent,
      task: TaskComponent,
      hint: HintComponent,
      document: DocumentComponent,
      Document: DocumentComponent,  # Capitalized version
      table: TableComponent,
      Table: TableComponent,  # Capitalized version
      img: ImageComponent,
      p: ParagraphComponent,
      example: ExampleComponent,
      input: InputComponent,
      output: OutputComponent,
      'output-format': OutputFormatComponent,
      'outputformat': OutputFormatComponent,
      list: ListComponent,
      item: ItemComponent,
      cp: CPComponent,
      'stepwise-instructions': StepwiseInstructionsComponent,
      'stepwiseinstructions': StepwiseInstructionsComponent,
      StepwiseInstructions: StepwiseInstructionsComponent,
      'human-message': HumanMessageComponent,
      'humanmessage': HumanMessageComponent,
      HumanMessage: HumanMessageComponent,
      qa: QAComponent,
      QA: QAComponent,
      let: LetComponent,
      Let: LetComponent,
      stylesheet: StylesheetComponent,
      Stylesheet: StylesheetComponent
    }.freeze

    def self.render_element(element, context)
      component_class = COMPONENT_MAPPING[element.tag_name] || TextComponent
      component = component_class.new(element, context)
      component.render
    end
  end
end
