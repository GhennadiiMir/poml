module Poml
  # Table component for displaying tabular data
  class TableComponent < Component
    require 'csv'
    require 'json'
    
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      records_attr = get_attribute('records')
      _columns_attr = get_attribute('columns')  # Not used but may be needed for future features
      parser = get_attribute('parser', 'auto')
      syntax = get_attribute('syntax')
      selected_columns = parse_array_attribute('selectedColumns')
      selected_records = parse_array_attribute('selectedRecords')
      max_records = parse_integer_attribute('maxRecords')
      max_columns = parse_integer_attribute('maxColumns')
      
      # Load data from source or use provided records
      data = if src
        load_table_data(src, parser)
      elsif records_attr
        parse_records_attribute(records_attr)
      elsif @element.children.any? { |child| child.tag_name == :tr }
        # Handle HTML-style table markup
        parse_html_table_children
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
    rescue
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
        begin
          JSON.parse(records_attr)
        rescue JSON::ParserError
          # Return empty records on parse error
          return { records: [], columns: [] }
        end
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
    
    def parse_array_attribute(attr_name)
      attr_value = get_attribute(attr_name)
      return nil unless attr_value
      
      if attr_value.is_a?(String)
        begin
          parsed = JSON.parse(attr_value)
          parsed.is_a?(Array) ? parsed : nil
        rescue JSON::ParserError
          # Try to handle as slice notation
          attr_value.include?(':') ? attr_value : nil
        end
      elsif attr_value.is_a?(Array)
        attr_value
      else
        nil
      end
    end
    
    def parse_integer_attribute(attr_name)
      attr_value = get_attribute(attr_name)
      return nil unless attr_value
      
      if attr_value.is_a?(String)
        attr_value.to_i
      elsif attr_value.is_a?(Integer)
        attr_value
      else
        nil
      end
    end
    
    def parse_html_table_children
      records = []
      columns = []
      
      # Extract rows from tr children
      @element.children.each do |child|
        next unless child.tag_name == :tr
        
        row_data = {}
        child.children.each_with_index do |cell, index|
          next unless cell.tag_name == :td || cell.tag_name == :th
          
          # Get cell content (render children to get text)
          cell_content = cell.children.map do |cell_child|
            Components.render_element(cell_child, @context)
          end.join('').strip
          
          # Use cell content as content, index as key for now
          column_key = "col_#{index}"
          row_data[column_key] = cell_content
          
          # Track columns
          unless columns.any? { |col| col[:field] == column_key }
            columns << { field: column_key, header: "Column #{index + 1}" }
          end
        end
        
        records << row_data unless row_data.empty?
      end
      
      { records: records, columns: columns }
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
      
      # Apply max records - simple truncation with ellipsis row
      if max_records && max_records > 0 && records.length > max_records
        truncated_records = records[0...max_records]
        # Add ellipsis row if we truncated
        if records.length > max_records && columns
          ellipsis_record = columns.each_with_object({}) { |col, record| record[col[:field]] = '...' }
          truncated_records << ellipsis_record
        end
        records = truncated_records
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

  # Object component for displaying structured data
  class ObjectComponent < Component
    require 'json'
    require 'yaml'
    
    def render
      apply_stylesheet
      
      data = get_attribute('data')
      syntax = get_attribute('syntax', 'json')
      
      return '' unless data
      
      if xml_mode?
        render_as_xml('obj', serialize_data(data, syntax))
      else
        serialize_data(data, syntax)
      end
    end
    
    private
    
    def serialize_data(data, syntax)
      case syntax.downcase
      when 'json'
        JSON.pretty_generate(data)
      when 'yaml', 'yml'
        YAML.dump(data)
      when 'xml'
        # Simple XML serialization for basic data structures
        serialize_to_xml(data)
      else
        data.to_s
      end
    rescue => e
      "[Error serializing data: #{e.message}]"
    end
    
    def serialize_to_xml(data, root_name = 'data', indent = 0)
      spaces = '  ' * indent
      
      case data
      when Hash
        result = ["#{spaces}<#{root_name}>"]
        data.each do |key, value|
          result << serialize_to_xml(value, key, indent + 1)
        end
        result << "#{spaces}</#{root_name}>"
        result.join("\n")
      when Array
        result = ["#{spaces}<#{root_name}>"]
        data.each_with_index do |item, index|
          result << serialize_to_xml(item, "item#{index}", indent + 1)
        end
        result << "#{spaces}</#{root_name}>"
        result.join("\n")
      else
        "#{spaces}<#{root_name}>#{escape_xml(data)}</#{root_name}>"
      end
    end
    
    def escape_xml(text)
      text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
    end
  end

  # Webpage component for displaying web content
  class WebpageComponent < Component
    def render
      apply_stylesheet
      
      url = get_attribute('url')
      src = get_attribute('src')
      buffer = get_attribute('buffer')
      base64 = get_attribute('base64')
      extract_text = get_attribute('extractText', false)
      selector = get_attribute('selector', 'body')
      _syntax = get_attribute('syntax', 'text')  # May be used for future formatting options
      
      content = if url
        fetch_webpage_content(url, selector, extract_text)
      elsif src
        read_html_file(src, selector, extract_text)
      elsif buffer
        process_html_content(buffer, selector, extract_text)
      elsif base64
        require 'base64'
        decoded = Base64.decode64(base64)
        process_html_content(decoded, selector, extract_text)
      else
        '[Webpage: no source specified]'
      end
      
      if xml_mode?
        render_as_xml('webpage', content)
      else
        content
      end
    end
    
    private
    
    def fetch_webpage_content(url, selector, extract_text)
      begin
        require 'net/http'
        require 'uri'
        
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.read_timeout = 10
        
        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = 'POML/1.0'
        
        response = http.request(request)
        
        if response.code == '200'
          process_html_content(response.body, selector, extract_text)
        else
          "[Webpage: HTTP #{response.code} error fetching #{url}]"
        end
      rescue => e
        "[Webpage: Error fetching #{url}: #{e.message}]"
      end
    end
    
    def read_html_file(file_path, selector, extract_text)
      begin
        # Resolve relative paths
        full_path = if file_path.start_with?('/')
          file_path
        else
          base_path = @context.source_path ? File.dirname(@context.source_path) : Dir.pwd
          File.join(base_path, file_path)
        end
        
        unless File.exist?(full_path)
          return "[Webpage: File not found: #{file_path}]"
        end
        
        html_content = File.read(full_path)
        process_html_content(html_content, selector, extract_text)
      rescue => e
        "[Webpage: Error reading file #{file_path}: #{e.message}]"
      end
    end
    
    def process_html_content(html_content, selector, extract_text)
      begin
        require 'nokogiri'
        
        doc = Nokogiri::HTML(html_content)
        
        # Apply selector if specified
        if selector && selector != 'body'
          selected = doc.css(selector).first
          return "[Webpage: Selector '#{selector}' not found]" unless selected
          doc = selected
        end
        
        if extract_text
          # Extract plain text
          doc.text.strip.gsub(/\s+/, ' ')
        else
          # Convert HTML to structured POML-like format
          convert_html_to_poml(doc)
        end
      rescue LoadError
        # Nokogiri not available, do simple text extraction
        if extract_text
          html_content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip
        else
          html_content
        end
      rescue => e
        "[Webpage: Error processing HTML: #{e.message}]"
      end
    end
    
    def convert_html_to_poml(element)
      case element.name.downcase
      when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
        level = element.name[1].to_i
        "#{('#' * level)} #{element.text.strip}\n\n"
      when 'p'
        "#{element.text.strip}\n\n"
      when 'ul', 'ol'
        items = element.css('li').map { |li| "- #{li.text.strip}" }
        "#{items.join("\n")}\n\n"
      when 'strong', 'b'
        "**#{element.text.strip}**"
      when 'em', 'i'
        "*#{element.text.strip}*"
      when 'code'
        "`#{element.text.strip}`"
      when 'pre'
        "```\n#{element.text.strip}\n```\n\n"
      when 'blockquote'
        lines = element.text.strip.split("\n")
        quoted = lines.map { |line| "> #{line}" }
        "#{quoted.join("\n")}\n\n"
      when 'a'
        href = element['href']
        text = element.text.strip
        href ? "[#{text}](#{href})" : text
      when 'img'
        alt = element['alt'] || 'Image'
        src = element['src']
        src ? "![#{alt}](#{src})" : "[#{alt}]"
      else
        # For other elements, process children recursively
        if element.children.any?
          element.children.map { |child| 
            child.text? ? child.text : convert_html_to_poml(child) 
          }.join('')
        else
          element.text.strip
        end
      end
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
end
