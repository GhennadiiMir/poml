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
      stylesheet = @context.respond_to?(:stylesheet) ? @context.stylesheet : {}
      style_rules = stylesheet[@element.tag_name.to_s] || {}
      style_rules.each do |attr, value|
        @element.attributes[attr] ||= value
      end

      # Apply class-based styles
      class_name = @element.attributes['classname'] || @element.attributes['className']
      if class_name
        class_rules = stylesheet[".#{class_name}"] || {}
        class_rules.each do |attr, value|
          @element.attributes[attr] ||= value
        end
      end
    end

    def xml_mode?
      if @context.respond_to?(:determine_syntax)
        @context.determine_syntax(@element) == 'xml'
      else
        false
      end
    end

    def inline?
      # Check if component should render inline
      get_attribute('inline', false) == true || get_attribute('inline') == 'true'
    end

    def render_with_inline_support(content)
      # Render content with inline vs block consideration
      if inline?
        render_inline(content)
      else
        render_block(content)
      end
    end

    def render_inline(content)
      # Inline rendering - no extra whitespace or newlines
      content.to_s.strip
    end

    def render_block(content)
      # Block rendering - traditional with proper spacing
      content.to_s.rstrip + "\n\n"
    end

    def render_as_xml(tag_name, content = nil, attributes = {})
      # Render as XML element with proper formatting
      content ||= render_children
      attrs_str = attributes.map { |k, v| " #{k}=\"#{v}\"" }.join('')
      
      # Check if this is an inline component that shouldn't have trailing newlines
      is_inline_component = is_inline_component_name?(self.class.name.split('::').last)
      
      if content.strip.empty?
        if is_inline_component
          "<#{tag_name}#{attrs_str}/>"
        else
          "<#{tag_name}#{attrs_str}/>\n"
        end
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
          if is_inline_component
            "<#{tag_name}#{attrs_str}>#{content}</#{tag_name}>"
          else
            "<#{tag_name}#{attrs_str}>#{content}</#{tag_name}>\n"
          end
        end
      end
    end

    # Helper method for robust file reading with encoding support
    def read_file_with_encoding(file_path, encoding: 'utf-8')
      # Normalize file path for cross-platform compatibility
      normalized_path = File.expand_path(file_path)
      
      # Try primary encoding first (UTF-8)
      begin
        return File.read(normalized_path, encoding: encoding)
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
        # If UTF-8 fails, try with binary mode and force encoding
        begin
          content = File.read(normalized_path, mode: 'rb')
          # Try to detect and convert encoding
          return content.force_encoding('utf-8').encode('utf-8', invalid: :replace, undef: :replace)
        rescue => encoding_error
          # If all else fails, read as binary and provide meaningful error
          raise "File encoding error for #{file_path}: #{e.message}. Original encoding detection failed: #{encoding_error.message}"
        end
      rescue => e
        # Re-raise other file reading errors with context
        raise "Error reading file #{file_path}: #{e.message}"
      end
    end

    # Helper method for reading file lines with encoding support
    def read_file_lines_with_encoding(file_path, encoding: 'utf-8')
      # Normalize file path for cross-platform compatibility
      normalized_path = File.expand_path(file_path)
      
      begin
        return File.readlines(normalized_path, encoding: encoding)
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
        # If UTF-8 fails, try with binary mode and force encoding line by line
        begin
          content = File.read(normalized_path, mode: 'rb')
          lines = content.force_encoding('utf-8').encode('utf-8', invalid: :replace, undef: :replace).lines
          return lines
        rescue => encoding_error
          raise "File encoding error for #{file_path}: #{e.message}. Original encoding detection failed: #{encoding_error.message}"
        end
      rescue => e
        raise "Error reading file #{file_path}: #{e.message}"
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
        
        # Add spacing if current element is text and next element is a block-level component
        if index < rendered_children.length - 1
          current_element = @element.children[index]
          next_element = @element.children[index + 1]
          
          # Only add spacing for block-level components, not inline components
          if current_element.text? && next_element.component?
            next_component_class = Components::COMPONENT_MAPPING[next_element.tag_name]
            if next_component_class && !is_inline_component?(next_component_class)
              result << "\n\n"
            end
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
      stylesheet = @context.respond_to?(:stylesheet) ? @context.stylesheet : {}
      transform = stylesheet.dig(component_name, 'captionTextTransform') ||
                  stylesheet.dig('cp', 'captionTextTransform')
      
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
    
    def inline_component?
      # Override this in inline components
      false
    end

    def unescape_xml_entities(text)
      # Unescape XML entities that were escaped during preprocessing
      text.gsub('&amp;', '&')
          .gsub('&lt;', '<')
          .gsub('&gt;', '>')
          .gsub('&quot;', '"')
          .gsub('&apos;', "'")
    end
    
    def self.inline_component_classes
      # List of component classes that should be treated as inline
      @inline_component_classes ||= []
    end
    
    def self.register_inline_component(component_class)
      inline_component_classes << component_class
    end
    
    private
    
    def is_inline_component?(component_class)
      # Check if the component class is registered as inline
      # For now, we'll use a simple list of known inline formatting components
      inline_component_names = %w[
        BoldComponent ItalicComponent UnderlineComponent StrikethroughComponent 
        CodeComponent InlineComponent
      ]
      
      component_class_name = component_class.name.split('::').last
      inline_component_names.include?(component_class_name)
    end
    
    def is_inline_component_name?(component_class_name)
      # Check if the component class name is registered as inline
      inline_component_names = %w[
        BoldComponent ItalicComponent UnderlineComponent StrikethroughComponent 
        CodeComponent InlineComponent
      ]
      
      inline_component_names.include?(component_class_name)
    end
  end

  # Component registry and factory
  module Components
    # Component mapping will be defined in main components.rb after all components are loaded
    COMPONENT_MAPPING = {}

    def self.render_element(element, context)
      # Try to find component using multiple key formats for compatibility
      tag_name = element.tag_name
      
      # In HTML output format, preserve HTML elements as-is
      if context.output_format == 'html' && is_html_element?(element)
        return render_html_element_as_is(element, context)
      end
      
      component_class = COMPONENT_MAPPING[tag_name] || 
                       COMPONENT_MAPPING[tag_name.to_s] || 
                       COMPONENT_MAPPING[tag_name.to_sym]
      
      # Use UnknownComponent for unrecognized tags (except :text which should use TextComponent)
      if component_class.nil?
        component_class = tag_name == :text ? TextComponent : UnknownComponent
      end
      
      component = component_class.new(element, context)
      component.render
    end
    
    private
    
    def self.is_html_element?(element)
      # Common HTML elements that should be preserved in HTML format
      html_elements = [:b, :i, :u, :strong, :em, :span, :div, :p, :h1, :h2, :h3, :h4, :h5, :h6, 
                      :table, :thead, :tbody, :tfoot, :tr, :th, :td, :ul, :ol, :li, :a, :img, :code]
      
      return html_elements.include?(element.tag_name)
    end
    
    def self.render_html_element_as_is(element, context)
      tag_name = element.tag_name.to_s
      
      # Build attributes string
      attr_string = ""
      if element.attributes && !element.attributes.empty?
        attr_string = element.attributes.map { |k, v| %{#{k}="#{v}"} }.join(" ")
        attr_string = " " + attr_string
      end
      
      # Render children
      children_content = element.children.map { |child| render_element(child, context) }.join('')
      content = children_content.empty? ? element.content : children_content
      
      # Return as HTML element
      if content.empty?
        "<#{tag_name}#{attr_string} />"
      else
        "<#{tag_name}#{attr_string}>#{content}</#{tag_name}>"
      end
    end
  end
end
