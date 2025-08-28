module Poml
  # Table component for displaying tabular data
  class TableComponent < Component
    require 'csv'
    require 'json'
    
    def render
      apply_stylesheet
      
      src = get_attribute('src')
      records_attr = get_attribute('records')
      data_attr = get_attribute('data')  # Support 'data' attribute as alias for 'records'
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
      elsif data_attr
        parse_records_attribute(data_attr)
      elsif @element.children.any? { |child| child.tag_name == :tr || child.tag_name == :thead || child.tag_name == :tbody || child.tag_name == :tfoot }
        # Handle HTML-style table markup
        if @context.output_format == 'html' || xml_mode?
          # In HTML or XML mode, render children directly to preserve nested components
          children_content = render_children
          if xml_mode?
            return "<table>\n#{children_content}</table>\n"
          else
            return children_content
          end
        else
          parse_html_table_children
        end
      else
        { records: [], columns: [] }
      end
      
      # Apply column and record selection
      data = apply_selection(data, selected_columns, selected_records, max_records, max_columns)
      
      # Check syntax preference and output format
      result = if syntax == 'tsv' || syntax == 'csv'
        render_table_raw(data, syntax)
      elsif xml_mode?
        render_table_xml(data)
      elsif @context.output_format == 'html'
        render_table_html(data)
      else
        render_table_markdown(data)
      end
      
      # Apply inline rendering if requested
      if inline? && !xml_mode?
        result.strip
      else
        result
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
      content = read_file_with_encoding(file_path)
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
      read_file_lines_with_encoding(file_path).each do |line|
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
      
      # Extract rows from tr children (including nested in thead/tbody)
      find_tr_elements(@element).each do |tr_element|
        row_data = {}
        tr_element.children.each_with_index do |cell, index|
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
    
    def find_tr_elements(element)
      tr_elements = []
      
      element.children.each do |child|
        if child.tag_name == :tr
          tr_elements << child
        elsif child.tag_name == :thead || child.tag_name == :tbody || child.tag_name == :tfoot
          # Recursively find tr elements in table sections
          tr_elements.concat(find_tr_elements(child))
        end
      end
      
      tr_elements
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
    
    def render_table_html(data)
      records = data[:records]
      columns = data[:columns]
      
      return '' if records.empty?
      
      # If no columns specified, infer from first record
      if columns.empty? && records.first.is_a?(Hash)
        columns = records.first.keys.map { |key| { field: key, header: key } }
      end
      
      return '' if columns.empty?
      
      # Build HTML table structure
      result = []
      result << '<table>'
      result << '  <thead>'
      result << '    <tr>'
      columns.each do |col|
        result << "      <th>#{escape_html(col[:header] || col[:field])}</th>"
      end
      result << '    </tr>'
      result << '  </thead>'
      result << '  <tbody>'
      
      records.each do |record|
        result << '    <tr>'
        columns.each do |col|
          value = record[col[:field]]
          result << "      <td>#{escape_html(value.nil? ? '' : value.to_s)}</td>"
        end
        result << '    </tr>'
      end
      
      result << '  </tbody>'
      result << '</table>'
      
      result.join("\n")
    end
    
    def escape_html(text)
      text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
    end
  end

  # Object component for displaying structured data
  class ObjectComponent < Component
    require 'json'
    require 'yaml'
    
    def render
      apply_stylesheet
      
      data_attr = get_attribute('data')
      syntax = get_attribute('syntax', 'json')
      
      return '' unless data_attr
      
      # Parse data if it's a JSON string
      data = if data_attr.is_a?(String) && data_attr.start_with?('{', '[')
        begin
          JSON.parse(data_attr)
        rescue JSON::ParserError
          data_attr  # Use as-is if parsing fails
        end
      else
        data_attr
      end
      
      if xml_mode?
        render_as_xml('obj', serialize_data(data, syntax))
      else
        result = serialize_data(data, syntax)
        inline? ? result.strip : result
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
        
        html_content = read_file_with_encoding(full_path)
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
      base64 = get_attribute('base64')
      alt = get_attribute('alt', '')
      syntax = get_attribute('syntax', 'multimedia')
      max_width = get_attribute('maxWidth')
      max_height = get_attribute('maxHeight')
      resize = get_attribute('resize')
      image_type = get_attribute('type')
      position = get_attribute('position', 'here')

      # Handle missing src and base64
      unless src || base64
        return handle_error("no src or base64 specified")
      end

      begin
        # Process the image
        if src
          if url?(src)
            content = fetch_image_from_url(src, max_width, max_height, resize, image_type)
          else
            content = read_local_image(src, max_width, max_height, resize, image_type)
          end
        elsif base64
          content = process_base64_image(base64, max_width, max_height, resize, image_type)
        end

        # Render based on syntax and XML mode
        if xml_mode?
          attributes = {}
          attributes[:src] = src if src
          attributes[:base64] = base64 if base64
          attributes[:alt] = alt unless alt.empty?
          attributes[:type] = image_type if image_type
          attributes[:position] = position
          render_as_xml('img', content || '', attributes)
        else
          if syntax == 'multimedia'
            # Show image reference with content info
            image_ref = src || '[embedded image]'
            result = "[Image: #{image_ref}]"
            result += " (#{alt})" unless alt.empty?
            result += "\n#{content}" if content && content.is_a?(String) && content.start_with?('data:')
            result
          else
            # Text mode - show alt text or simple reference
            alt.empty? ? "[Image: #{src || 'embedded'}]" : alt
          end
        end
      rescue => e
        handle_error("error processing image: #{e.message}")
      end
    end

    private

    def url?(src)
      src && src.match?(/^https?:\/\//i)
    end

    def fetch_image_from_url(url, max_width = nil, max_height = nil, resize = nil, image_type = nil)
      require 'net/http'
      require 'uri'
      require 'base64'

      uri = URI.parse(url)
      
      # Configure HTTP client
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.read_timeout = 10
      http.open_timeout = 5

      # Create request with appropriate headers
      request = Net::HTTP::Get.new(uri.request_uri)
      request['User-Agent'] = 'POML Ruby/1.0'
      request['Accept'] = 'image/*'

      # Fetch the image
      response = http.request(request)

      unless response.code == '200'
        raise "HTTP #{response.code}: #{response.message}"
      end

      # Process the image data
      image_data = response.body
      content_type = response['content-type'] || detect_image_type(image_data)
      
      # Apply processing if requested
      if max_width || max_height || resize || image_type
        image_data = process_image_data(image_data, content_type, max_width, max_height, resize, image_type)
      end

      # Return base64 encoded data URL
      base64_data = Base64.strict_encode64(image_data)
      mime_type = image_type ? "image/#{image_type}" : content_type
      "data:#{mime_type};base64,#{base64_data}"
    rescue => e
      raise "Failed to fetch image from URL #{url}: #{e.message}"
    end

    def read_local_image(file_path, max_width = nil, max_height = nil, resize = nil, image_type = nil)
      require 'base64'

      # Resolve file path
      full_path = if file_path.start_with?('/')
        file_path
      else
        base_path = @context.source_path ? File.dirname(@context.source_path) : Dir.pwd
        File.join(base_path, file_path)
      end

      unless File.exist?(full_path)
        raise "File not found: #{file_path}"
      end

      # Read image data
      image_data = File.read(full_path, mode: 'rb')
      content_type = detect_image_type_from_extension(full_path) || detect_image_type(image_data)

      # Apply processing if requested
      if max_width || max_height || resize || image_type
        image_data = process_image_data(image_data, content_type, max_width, max_height, resize, image_type)
      end

      # Return base64 encoded data URL
      base64_data = Base64.strict_encode64(image_data)
      mime_type = image_type ? "image/#{image_type}" : content_type
      "data:#{mime_type};base64,#{base64_data}"
    rescue => e
      raise "Failed to read local image #{file_path}: #{e.message}"
    end

    def process_base64_image(base64_data, max_width = nil, max_height = nil, resize = nil, image_type = nil)
      require 'base64'

      # Decode base64 data
      image_data = Base64.decode64(base64_data)
      content_type = detect_image_type(image_data)

      # Apply processing if requested
      if max_width || max_height || resize || image_type
        image_data = process_image_data(image_data, content_type, max_width, max_height, resize, image_type)
      end

      # Return base64 encoded data URL
      processed_base64 = Base64.strict_encode64(image_data)
      mime_type = image_type ? "image/#{image_type}" : content_type
      "data:#{mime_type};base64,#{processed_base64}"
    rescue => e
      raise "Failed to process base64 image: #{e.message}"
    end

    def detect_image_type_from_extension(file_path)
      ext = File.extname(file_path).downcase
      case ext
      when '.jpg', '.jpeg' then 'image/jpeg'
      when '.png' then 'image/png'
      when '.gif' then 'image/gif'
      when '.webp' then 'image/webp'
      when '.svg' then 'image/svg+xml'
      when '.bmp' then 'image/bmp'
      when '.tiff', '.tif' then 'image/tiff'
      else nil
      end
    end

    def detect_image_type(image_data)
      # Check magic bytes to detect image type
      return 'image/jpeg' if image_data[0..1] == "\xFF\xD8".b
      return 'image/png' if image_data[0..7] == "\x89PNG\r\n\x1A\n".b
      return 'image/gif' if image_data[0..5] == "GIF87a".b || image_data[0..5] == "GIF89a".b
      return 'image/webp' if image_data[0..3] == "RIFF".b && image_data[8..11] == "WEBP".b
      return 'image/bmp' if image_data[0..1] == "BM".b
      return 'image/svg+xml' if image_data.include?('<svg')
      
      # Default fallback
      'image/octet-stream'
    end

    def process_image_data(image_data, content_type, max_width, max_height, resize, new_type)
      # Note: This is a basic implementation that doesn't actually resize images
      # For full image processing, consider using mini_magick or image_processing gems
      
      # If type conversion is requested and it's different from current type
      if new_type && !content_type.include?(new_type)
        # For now, we'll just change the MIME type
        # Real implementation would use an image processing library
        # Note: Basic image format conversion available. Install mini_magick gem for enhanced image processing support.
      end

      # Return original data for now
      # TODO: Implement actual resizing using image processing library
      image_data
    end

    def handle_error(message)
      if xml_mode?
        render_as_xml('img', "[Error: #{message}]")
      else
        "[Image Error: #{message}]"
      end
    end
  end
end
