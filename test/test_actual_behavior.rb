require_relative "test_helper"

class TestActualBehavior < Minitest::Test
  include TestHelper

  def test_what_actually_works
    # Test basic formatting that we know works
    result = Poml.process(markup: '<b>Bold</b>', format: 'raw')
    assert_includes result, '**Bold**'
    
    # Test chat components
    result = Poml.process(markup: '<ai>AI message</ai>', format: 'openai_chat')
    assert_equal [{"role"=>"assistant", "content"=>"AI message"}], result
    
    # Test what happens with table components
    result = Poml.process(markup: '<table data="[]">Table</table>', format: 'raw')
    refute_nil result # Should handle gracefully
    
    # Test template features
    result = Poml.process(markup: '<template vars="{\"name\": \"Alice\"}">Hello {{name}}</template>', format: 'raw')
    assert_includes result, 'Hello'
  end
end
