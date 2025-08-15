require 'rexml/document'

module Poml
  # Element represents a parsed POML element
  class Element
    attr_accessor :tag_name, :attributes, :content, :children

    def initialize(tag_name:, attributes: {}, content: '', children: [])
      @tag_name = tag_name
      @attributes = attributes || {}
      @content = content || ''
      @children = children || []
    end

    def text?
      @tag_name == :text
    end

    def component?
      !text?
    end
  end

  # Parser for POML markup
  class Parser
    def initialize(context)
      @context = context
      @template_engine = TemplateEngine.new(context)
    end

    def parse(content)
      # Handle escape characters
      content = unescape_poml(content)
      
      # Remove XML comments but preserve surrounding whitespace
      content = content.gsub(/(\s*)<!--.*?-->(\s*)/m) do |match|
        before_space = $1
        after_space = $2
        # Preserve the original spacing pattern, but normalize to a single space if there was whitespace
        if before_space.length > 0 || after_space.length > 0
          ' '
        else
          ''
        end
      end
      
      # Apply template substitutions
      content = @template_engine.substitute(content)

      # Check if content is wrapped in <poml> tags and extract syntax
      content = content.strip
      if content =~ /\A<poml\b([^>]*)?>(.*)<\/poml>\s*\z/m
        poml_attributes = $1
        content = $2
        
        # Extract syntax attribute if present
        if poml_attributes && poml_attributes =~ /syntax\s*=\s*["']([^"']+)["']/
          @context.syntax = $1
        end
      end

      # Pre-process stylesheets before parsing other components
      preprocess_stylesheets(content)

      # Parse as XML with whitespace preservation
      begin
        doc = REXML::Document.new("<root>#{content}</root>")
        # Preserve whitespace in text nodes
        doc.context[:ignore_whitespace_nodes] = :none
        parse_element(doc.root)
      rescue => e
        # If XML parsing fails, treat as plain text
        puts "XML parsing failed: #{e.message}" if defined?(DEBUG)
        [Element.new(tag_name: :text, content: content)]
      end
    end

    private

    def parse_element(xml_element)
      elements = []

      xml_element.children.each do |child|
        case child
        when REXML::Text
          text_content = child.to_s
          next if text_content.strip.empty?  # Only skip if completely empty when stripped
          
          # Check if the content (after removing newlines) ends with a space
          content_no_newlines = text_content.gsub(/\n/, ' ')
          preserves_trailing_space = content_no_newlines.rstrip != content_no_newlines
          
          # Normalize the text: strip leading/trailing whitespace 
          normalized = text_content.strip
          
          # Add back trailing space if it was significant (i.e., there was a space before newlines)
          normalized += ' ' if preserves_trailing_space
          
          next if normalized.empty?
          elements << Element.new(tag_name: :text, content: normalized)
        when REXML::Element
          # Convert REXML attributes to string hash
          attrs = {}
          child.attributes.each do |name, value|
            attrs[name.downcase] = value.to_s
          end
          
          elements << Element.new(
            tag_name: child.name.downcase.to_sym,
            attributes: attrs,
            content: extract_text_content(child),
            children: parse_element(child)
          )
        end
      end

      elements
    end

    def extract_text_content(xml_element)
      # Extract direct text content (not from child elements)
      text_nodes = xml_element.children.select { |child| child.is_a?(REXML::Text) }
      text_nodes.map(&:to_s).join('').strip
    end

    def unescape_poml(text)
      # Handle POML escape characters
      text.gsub(/#quot;/, '"')
          .gsub(/#apos;/, "'")
          .gsub(/#amp;/, '&')
          .gsub(/#lt;/, '<')
          .gsub(/#gt;/, '>')
          .gsub(/#hash;/, '#')
          .gsub(/#lbrace;/, '{')
          .gsub(/#rbrace;/, '}')
    end
    
    def preprocess_stylesheets(content)
      # Extract and process stylesheet elements before main parsing
      content.scan(/<stylesheet\b[^>]*>(.*?)<\/stylesheet>/m) do |stylesheet_content|
        begin
          stylesheet_text = stylesheet_content[0].strip
          if stylesheet_text.start_with?('{') && stylesheet_text.end_with?('}')
            stylesheet = JSON.parse(stylesheet_text)
            @context.stylesheet.merge!(stylesheet) if stylesheet.is_a?(Hash)
          end
        rescue => e
          # Silently fail JSON parsing errors
        end
      end
    end
  end
end
