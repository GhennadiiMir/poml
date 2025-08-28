module Poml
  # Tool component for declarative tool definition
  class ToolComponent < Component
    def render
      name = get_attribute('name')
      return '' unless name
      
      # Build tool definition from declarative syntax
      tool_def = {
        'name' => name,
        'description' => extract_description,
        'parameters' => extract_parameters
      }
      
      # Register the tool
      @context.tools ||= []
      @context.tools << tool_def
      
      # Tools components don't produce output by default
      ''
    end
    
    private
    
    def extract_description
      description_element = @element.children.find { |child| child.name == 'description' }
      return description_element&.content&.strip if description_element
      
      # Fallback to description attribute
      get_attribute('description') || ''
    end
    
    def extract_parameters
      parameter_elements = @element.children.select { |child| child.name == 'parameter' }
      
      if parameter_elements.empty?
        # If no parameter elements, return empty object structure
        return {
          'type' => 'object',
          'properties' => {},
          'required' => []
        }
      end
      
      properties = {}
      required = []
      
      parameter_elements.each do |param_element|
        param_name = param_element.attributes['name']
        next unless param_name
        
        param_type = param_element.attributes['type'] || 'string'
        param_required = param_element.attributes['required']
        param_description = param_element.content&.strip
        
        # If the parameter has a description child element, use that instead
        description_child = param_element.children.find { |child| child.name == 'description' }
        if description_child
          param_description = description_child.content&.strip
        end
        
        properties[param_name] = {
          'type' => param_type
        }
        
        properties[param_name]['description'] = param_description if param_description && !param_description.empty?
        
        # Handle required flag
        if param_required == 'true' || param_required == true
          required << param_name
        end
      end
      
      {
        'type' => 'object',
        'properties' => properties,
        'required' => required
      }
    end
  end
end
