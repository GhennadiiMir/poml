require_relative "test_helper"

class TestTableComponent < Minitest::Test
  include TestHelper

  def test_table_with_json_records
    markup = '<table records="[{\"name\": \"John\", \"age\": 30}, {\"name\": \"Jane\", \"age\": 25}]">Table</table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should render as markdown table
    assert_includes result, '| name | age |'
    assert_includes result, '| --- | --- |'
    assert_includes result, '| John | 30 |'
    assert_includes result, '| Jane | 25 |'
  end

  def test_table_with_html_markup
    markup = '<table><tr><td>Product</td><td>Price</td></tr><tr><td>Laptop</td><td>$999</td></tr></table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should render as markdown table with auto-generated column headers
    assert_includes result, '| Column 1 | Column 2 |'
    assert_includes result, 'Product'
    assert_includes result, 'Price'
    assert_includes result, 'Laptop'
    assert_includes result, '$999'
  end

  def test_table_with_csv_source
    csv_path = File.join(fixture_path, 'tables', 'employees.csv')
    markup = "<table src=\"#{csv_path}\">CSV Table</table>"
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'name'
    assert_includes result, 'age'
    assert_includes result, 'department'
    assert_includes result, 'John Smith'
    assert_includes result, 'Engineering'
  end

  def test_table_with_selected_columns
    markup = '<table records="[{\"name\": \"John\", \"age\": 30, \"city\": \"NYC\"}, {\"name\": \"Jane\", \"age\": 25, \"city\": \"LA\"}]" selectedColumns="[\"name\", \"age\"]">Table</table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'name'
    assert_includes result, 'age'
    refute_includes result, 'city'
    assert_includes result, 'John'
    assert_includes result, '30'
  end

  def test_table_with_max_records
    records = (1..10).map { |i| "{\"id\": #{i}, \"value\": \"item#{i}\"}" }.join(', ')
    markup = "<table records=\"[#{records}]\" maxRecords=\"3\">Large Table</table>"
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should show limited records with ellipsis
    assert_includes result, 'item1'
    assert_includes result, 'item10'
    assert_includes result, '...'
  end

  def test_empty_table
    markup = '<table records="[]">Empty Table</table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle empty gracefully
    assert_kind_of String, result
  end

  def test_table_error_handling
    # Test with malformed JSON
    markup = '<table records="[malformed">Invalid Table</table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should not crash
    assert_kind_of String, result
  end

  def test_table_with_different_output_formats
    markup = '<table records="[{\"name\": \"Test\", \"value\": 123}]">Table</table>'
    
    ['raw', 'dict', 'openai_chat'].each do |format|
      result = Poml.process(markup: markup, format: format)
      assert_kind_of(format == 'openai_chat' ? Array : (format == 'dict' ? Hash : String), result)
    end
  end

  def test_table_with_fixture_files
    file_content = load_fixture('tables/json_table.poml')
    file_path = create_temp_poml_file(file_content)
    
    result = Poml.process(markup: file_path, format: 'raw')
    assert_includes result, 'John'
    assert_includes result, 'Jane'
    assert_includes result, 'Bob'
    
    File.unlink(file_path)
  end
end
