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
      
      # Pre-process to handle JSON in attributes (convert \" to &quot; inside attribute values)
      content = preprocess_json_attributes(content)
      
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
      
      # Convert HTML-style void elements to XML self-closing format
      content = preprocess_void_elements(content)
      
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
          
          # For inline content, preserve spaces but normalize newlines
          # Convert newlines to single spaces to avoid formatting issues
          normalized = text_content.gsub(/\s*\n\s*/, ' ')
          
          # Trim only if the content is just whitespace, otherwise preserve leading/trailing spaces
          if normalized.strip.empty?
            next
          end
          
          elements << Element.new(tag_name: :text, content: normalized)
        when REXML::Element
          # Convert REXML attributes to string hash
          attrs = {}
          child.attributes.each do |name, value|
            attrs[name.downcase] = value.to_s
          end
          
          # Check for conditional and loop attributes before creating element
          if_condition = attrs['if']
          for_attribute = attrs['for']
          
          # Handle conditional rendering
          if if_condition && !evaluate_if_condition(if_condition)
            next # Skip this element
          end
          
          # Handle for loop rendering
          if for_attribute
            loop_elements = render_for_loop(child, attrs, for_attribute)
            elements.concat(loop_elements)
          else
            elements << Element.new(
              tag_name: child.name.downcase.to_sym,
              attributes: attrs,
              content: extract_text_content(child),
              children: parse_element(child)
            )
          end
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
        rescue
          # Silently fail JSON parsing errors
        end
      end
    end
    
    def evaluate_if_condition(condition)
      value = @template_engine.evaluate_attribute_expression(condition)
      !!value
    end
    
    def render_for_loop(xml_element, attrs, for_attribute)
      # Parse for attribute like "i in [1,2,3]" or "item in items"
      if for_attribute =~ /^(\w+)\s+in\s+(.+)$/
        loop_var = $1
        list_expr = $2.strip
        
        # Evaluate the list expression
        list = @template_engine.evaluate_attribute_expression(list_expr)
        return [] unless list.is_a?(Array)
        
        # Create elements for each item in the list
        elements = []
        list.each_with_index do |item, index|
          # Create loop context
          old_loop_var = @context.variables[loop_var]
          old_loop_context = @context.variables['loop']
          
          @context.variables[loop_var] = item
          @context.variables['loop'] = {
            'index' => index,
            'length' => list.length,
            'first' => index == 0,
            'last' => index == list.length - 1
          }
          
          # Remove for attribute and process element normally
          loop_attrs = attrs.dup
          loop_attrs.delete('for')
          
          element = Element.new(
            tag_name: xml_element.name.downcase.to_sym,
            attributes: loop_attrs,
            content: extract_text_content(xml_element),
            children: parse_element(xml_element)
          )
          
          elements << element
          
          # Restore previous context
          if old_loop_var
            @context.variables[loop_var] = old_loop_var
          else
            @context.variables.delete(loop_var)
          end
          
          if old_loop_context
            @context.variables['loop'] = old_loop_context
          else
            @context.variables.delete('loop')
          end
        end
        
        elements
      else
        # Invalid for syntax, return empty
        []
      end
    end
    
    def preprocess_void_elements(content)
      # List of HTML void elements that should be self-closing in XML
      # Note: 'meta' is removed from this list because POML meta components can have content
      # Note: 'input' is removed because POML input components (for examples) can have content
      void_elements = %w[br hr img area base col embed link param source track wbr]
      
      # Convert <element> to <element/> for void elements, but only if not already self-closing
      void_elements.each do |element|
        # Match opening tag that's not already self-closing
        # Use a more specific pattern to avoid matching already self-closing tags
        pattern = /<(#{element})(\s+[^>\/]*?)?(?<!\/)>/i
        content = content.gsub(pattern) do |match|
          element_name = $1
          attributes = $2 || ''
          "<#{element_name}#{attributes}/>"
        end
      end
      
      content
    end
    
    def preprocess_json_attributes(content)
      # Convert problematic characters in attribute values to make them valid XML
      content = content.gsub(/\\"/, '&quot;')  # Handle JSON quotes
      
      # Handle comparison operators in attribute values
      content = content.gsub(/(\w+\s*=\s*"[^"]*?)(<)([^"]*?")/m, '\1&lt;\3')
      content = content.gsub(/(\w+\s*=\s*"[^"]*?)(>)([^"]*?")/m, '\1&gt;\3')
      
      content
    end
  end
end
