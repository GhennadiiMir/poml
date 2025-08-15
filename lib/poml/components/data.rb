module Poml
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
end
