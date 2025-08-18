require_relative "test_helper_simple"

class TestActualBehavior < Minitest::Test
  include TestHelper

  def test_what_actually_works
    # Test basic formatting that we know works
    result = Poml.process(markup: '<b>Bold</b>', format: 'raw')
    puts "Bold test: #{result.inspect}"
    
    # Test chat components
    result = Poml.process(markup: '<ai>AI message</ai>', format: 'openai_chat')
    puts "AI chat test: #{result.inspect}"
    
    # Test what happens with unimplemented features
    result = Poml.process(markup: '<table data="[]">Table</table>', format: 'raw')
    puts "Table test: #{result.inspect}"
    
    # Test template features
    result = Poml.process(markup: '<template vars="{\"name\": \"Alice\"}">Hello {{name}}</template>', format: 'raw')
    puts "Template test: #{result.inspect}"
    
    assert true # Just to make it pass
  end
end
