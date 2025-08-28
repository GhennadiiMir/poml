require_relative 'test_helper'

class TestInlineRendering < Minitest::Test
  include TestHelper

  def test_header_inline_rendering
    # Block rendering (default)
    block_markup = '<h1>Test Header</h1>'
    block_result = Poml.process(markup: block_markup, format: 'raw', chat: false)
    assert_equal "# Test Header", block_result.strip

    # Inline rendering
    inline_markup = '<h1 inline="true">Test Header</h1>'
    inline_result = Poml.process(markup: inline_markup, format: 'raw', chat: false)
    assert_equal "Test Header", inline_result.strip
  end

  def test_table_inline_rendering
    data = [{"name" => "John", "age" => 30}, {"name" => "Jane", "age" => 25}]
    
    # Block rendering (default) - should include newlines
    block_markup = %{<table data='#{data.to_json}'></table>}
    block_result = Poml.process(markup: block_markup, format: 'raw', chat: false)
    assert_includes block_result, "\n"
    assert_includes block_result, "| name | age |"
    
    # Inline rendering - should be stripped
    inline_markup = %{<table inline="true" data='#{data.to_json}'></table>}
    inline_result = Poml.process(markup: inline_markup, format: 'raw', chat: false)
    # Should not start or end with whitespace when inline
    assert_equal inline_result, inline_result.strip
    assert_includes inline_result, "| name | age |"
  end

  def test_object_inline_rendering
    data = {"name" => "John", "age" => 30}
    
    # Block rendering (default)
    block_markup = %{<obj data='#{data.to_json}'></obj>}
    block_result = Poml.process(markup: block_markup, format: 'raw', chat: false)
    assert_includes block_result, '"name": "John"'
    
    # Inline rendering - should be stripped
    inline_markup = %{<obj inline="true" data='#{data.to_json}'></obj>}
    inline_result = Poml.process(markup: inline_markup, format: 'raw', chat: false)
    # Should not start or end with whitespace when inline
    assert_equal inline_result, inline_result.strip
    assert_includes inline_result, '"name": "John"'
  end

  def test_code_inline_rendering_compatibility
    # Code component already has its own inline logic, should work with new base inline attribute too
    block_markup = '<code inline="false" lang="ruby">puts "hello"</code>'
    block_result = Poml.process(markup: block_markup, format: 'raw', chat: false)
    assert_includes block_result, "```ruby"
    
    # Test that base inline attribute also works
    inline_markup = '<code inline="true" lang="ruby">puts "hello"</code>'
    inline_result = Poml.process(markup: inline_markup, format: 'raw', chat: false)
    assert_equal "`puts \"hello\"`", inline_result.strip
  end

  def test_example_inline_rendering
    # Block rendering (default)
    block_markup = '<example>This is an example</example>'
    block_result = Poml.process(markup: block_markup, format: 'raw', chat: false)
    assert_includes block_result, "This is an example"
    
    # Inline rendering
    inline_markup = '<example inline="true">This is an example</example>'
    inline_result = Poml.process(markup: inline_markup, format: 'raw', chat: false)
    assert_equal "This is an example", inline_result.strip
  end

  def test_cp_inline_rendering
    # Block rendering (default)
    block_markup = '<cp caption="Test">This is a code paragraph</cp>'
    block_result = Poml.process(markup: block_markup, format: 'raw', chat: false)
    assert_includes block_result, "# Test"
    assert_includes block_result, "This is a code paragraph"
    
    # Inline rendering
    inline_markup = '<cp inline="true" caption="Test">This is a code paragraph</cp>'
    inline_result = Poml.process(markup: inline_markup, format: 'raw', chat: false)
    assert_equal "# Test\n\nThis is a code paragraph", inline_result.strip
  end

  def test_inline_with_xml_mode
    # Test that inline rendering works in XML mode too
    inline_markup = '<h1 inline="true">Test Header</h1>'
    xml_result = Poml.process(markup: inline_markup, format: 'raw', syntax: 'xml', chat: false)
    # In XML mode, should still render XML but with inline attributes
    assert_includes xml_result, "<h"
    assert_includes xml_result, "Test Header"
    assert_includes xml_result, "</h>"
  end

  def test_mixed_inline_and_block_components
    # Mix inline and block components in same markup
    mixed_markup = %{
      <h1>Block Header</h1>
      <b inline="true">Inline Bold</b>
      <table inline="true" data='[{"name": "John"}]'></table>
    }
    
    result = Poml.process(markup: mixed_markup, format: 'raw', chat: false)
    
    # Block header should have markdown
    assert_includes result, "# Block Header"
    
    # Inline components should be in the result
    assert_includes result, "**Inline Bold**"
    assert_includes result, "| name |"
  end

  def test_inline_attribute_inheritance
    # Test that inline attribute works for components that extend base functionality
    bold_markup = '<b inline="true">Bold text</b>'
    bold_result = Poml.process(markup: bold_markup, format: 'raw', chat: false)
    assert_equal "**Bold text**", bold_result.strip
    
    italic_markup = '<i inline="true">Italic text</i>'
    italic_result = Poml.process(markup: italic_markup, format: 'raw', chat: false)
    assert_equal "*Italic text*", italic_result.strip
  end
end
