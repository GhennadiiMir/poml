require_relative "test_helper"

class TestErrorHandling < Minitest::Test
  include TestHelper

  def test_malformed_xml_tags
    markup = '<b>Unclosed bold tag'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle malformed XML gracefully
    assert_kind_of String, result
  end

  def test_unknown_component
    markup = '<unknown>Unknown component</unknown>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle unknown components gracefully
    assert_kind_of String, result
  end

  def test_missing_required_attributes
    markup = '<table>Missing data attribute</table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle missing attributes gracefully
    assert_kind_of String, result
  end

  def test_invalid_json_in_attributes
    markup = '<table data="[invalid json">Invalid JSON</table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle invalid JSON gracefully
    assert_kind_of String, result
  end

  def test_circular_template_references
    # This would test if template A includes template B which includes template A
    markup = '<template src="circular_a.poml">Circular reference</template>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle circular references gracefully
    assert_kind_of String, result
  end

  def test_empty_markup
    result = Poml.process(markup: '', format: 'raw')
    
    assert_equal '', result
  end

  def test_nil_markup
    assert_raises(TypeError) do
      Poml.process(markup: nil, format: 'raw')
    end
  end

  def test_invalid_format
    markup = '<b>Bold text</b>'
    
    assert_raises(Poml::Error) do
      Poml.process(markup: markup, format: 'invalid_format')
    end
  end

  def test_deeply_nested_components
    # Test with very deep nesting to check for stack overflow
    nested_markup = '<b>' * 100 + 'Deep nesting' + '</b>' * 100
    result = Poml.process(markup: nested_markup, format: 'raw')
    
    # Should handle deep nesting
    assert_kind_of String, result
    assert_includes result, 'Deep nesting'
  end

  def test_large_content_handling
    # Test with very large content
    large_content = 'A' * 10000
    markup = "<b>#{large_content}</b>"
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle large content
    assert_kind_of String, result
    assert_includes result, large_content
  end

  def test_special_xml_characters
    markup = '<b>&lt;script&gt;alert("xss")&lt;/script&gt;</b>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle special XML characters properly
    assert_kind_of String, result
    assert_includes result, '&lt;script&gt;'
  end

  def test_unicode_handling
    markup = '<b>Unicode: 中文 🚀 àáâãäå</b>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_kind_of String, result
    assert_includes result, '中文'
    assert_includes result, '🚀'
    assert_includes result, 'àáâãäå'
  end

  def test_mixed_format_error_handling
    markup = '<ai>Hello</ai><table data="invalid">Table</table>'
    
    # Should handle mixed valid/invalid components
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, result
    
    result = Poml.process(markup: markup, format: 'dict')
    assert_kind_of Hash, result
  end

  def test_invalid_variable_references
    markup = '<template vars="{\"name\": \"John\"}">Hello {{invalid.variable.path}}</template>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle invalid variable references gracefully
    assert_kind_of String, result
  end

  def test_memory_intensive_operations
    # Test with many variables to check memory usage
    vars = {}
    1000.times { |i| vars["var#{i}"] = "value#{i}" }
    
    markup = '<template vars="' + vars.to_json + '">Template with many vars</template>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle many variables
    assert_kind_of String, result
  end

  def test_concurrent_processing
    # Test thread safety (if applicable)
    markup = '<b>Concurrent test</b>'
    
    threads = []
    results = []
    
    10.times do
      threads << Thread.new do
        results << Poml.process(markup: markup, format: 'raw')
      end
    end
    
    
    threads.each(&:join)
    
    # All results should be consistent
    assert_equal 10, results.length
    results.each do |result|
      assert_includes result, 'Concurrent test'
    end
  end
  
  # Enhanced unknown component tests (based on debug_unknown_component.rb)
  def test_unknown_component_detailed
    markup = '<unknowncomponent>Content</unknowncomponent>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should include both component name and content for debugging
    assert_includes result, 'unknowncomponent', "Result should include component name for debugging"
    assert_includes result, 'Content', "Result should include component content"
  end
  
  def test_multiple_unknown_components
    markup = '<unknown1>Content1</unknown1><unknown2>Content2</unknown2>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle multiple unknown components
    assert_includes result, 'unknown1'
    assert_includes result, 'Content1'
    assert_includes result, 'unknown2'
    assert_includes result, 'Content2'
  end
  
  def test_unknown_component_with_attributes
    markup = '<unknowncomp attr1="value1" attr2="value2">Content</unknowncomp>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle unknown components with attributes gracefully
    assert_includes result, 'unknowncomp'
    assert_includes result, 'Content'
  end
  
  def test_nested_unknown_components
    markup = '<unknown><nested>Content</nested></unknown>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle nested unknown components
    assert_includes result, 'unknown'
    assert_includes result, 'nested'
    assert_includes result, 'Content'
  end
  
  def test_mixed_known_unknown_components
    markup = '<b>Bold</b><unknown>Unknown</unknown><i>Italic</i>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should process known components normally and handle unknown gracefully
    assert_includes result, '**Bold**', "Should process bold component"
    assert_includes result, '*Italic*', "Should process italic component"
    assert_includes result, 'unknown', "Should include unknown component name"
    assert_includes result, 'Unknown', "Should include unknown component content"
  end
end