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
  end

  # Component registry and factory
  module Components
    # Component mapping will be defined in main components.rb after all components are loaded
    COMPONENT_MAPPING = {}

    def self.render_element(element, context)
      component_class = COMPONENT_MAPPING[element.tag_name] || TextComponent
      component = component_class.new(element, context)
      component.render
    end
  end
end
