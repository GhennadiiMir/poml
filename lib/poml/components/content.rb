module Poml
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
        elsif file_path.downcase.end_with?('.docx')
          read_docx_content(file_path)
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

    def read_docx_content(file_path)
      # Try to extract text from .docx file using antiword or textutil (macOS)
      # First try textutil (available on macOS)
      result = `textutil -convert txt -stdout "#{file_path}" 2>/dev/null`
      if $?.success? && !result.strip.empty?
        return result
      end

      # Try pandoc if available
      result = `pandoc "#{file_path}" -t plain 2>/dev/null`
      if $?.success? && !result.strip.empty?
        return result
      end

      # Try unzip to extract document.xml and parse it
      begin
        require 'zip'
        content = ""
        Zip::File.open(file_path) do |zip_file|
          entry = zip_file.find_entry("word/document.xml")
          if entry
            xml_content = entry.get_input_stream.read
            # Simple XML text extraction (not perfect but better than binary)
            content = xml_content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip
          end
        end
        return content unless content.empty?
      rescue
        # Zip gem not available or error occurred
      end

      # Fallback: indicate that document could not be processed
      "[Document: #{File.basename(file_path)} (Word document text extraction not available)]"
    end
  end

  # Paragraph component for basic text content
  class ParagraphComponent < Component
    def render
      apply_stylesheet
      
      content = @element.content.empty? ? render_children : @element.content
      "#{content}\n\n"
    end
  end
end
