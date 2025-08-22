require_relative 'test_helper'

class MinimalToolTest < Minitest::Test
  def test_meta_component_tools
    content = '<poml>
      <meta type="tool">
        {
          "name": "calculator",
          "description": "Perform arithmetic calculations",
          "parameters": {
            "type": "object",
            "properties": {
              "expression": {"type": "string"}
            }
          }
        }
      </meta>
      <human>Calculate 5 + 3</human>
    </poml>'
    
    result = Poml.to_dict(content)
    
    puts "Result structure:"
    puts JSON.pretty_generate(result)
    
    puts "\nAssertion checks:"
    puts "Has metadata key? #{result.key?('metadata')}"
    puts "Has tools key? #{result['metadata'].key?('tools')}"
    puts "Tools count: #{result['metadata']['tools'].length}"
    
    tool = result['metadata']['tools'].first
    puts "Tool name: #{tool['name']}"
    puts "Tool description includes 'arithmetic'? #{tool['description'].include?('arithmetic')}"
    
    assert result.key?('metadata')
    assert result['metadata'].key?('tools')
    assert_equal 1, result['metadata']['tools'].length
    
    assert_equal 'calculator', tool['name']
    assert_includes tool['description'], 'arithmetic'
    
    puts "All assertions passed!"
  end
end
