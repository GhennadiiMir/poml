require_relative "test_helper"

class TestFileComponents < Minitest::Test
  include TestHelper

  def setup
    # Create test files for file component testing
    @test_dir = File.join(File.dirname(__FILE__), 'fixtures', 'files')
    FileUtils.mkdir_p(@test_dir) unless Dir.exist?(@test_dir)
    
    @test_file = File.join(@test_dir, 'test.txt')
    File.write(@test_file, "This is a test file.\nWith multiple lines.\nFor testing file component.")
    
    @test_json = File.join(@test_dir, 'test.json')
    File.write(@test_json, '{"name": "John", "age": 30, "city": "New York"}')
    
    @test_csv = File.join(@test_dir, 'test.csv')
    File.write(@test_csv, "name,age,city\nJohn,30,New York\nJane,25,Boston")
  end

  def teardown
    # Clean up test files
    FileUtils.rm_rf(@test_dir) if Dir.exist?(@test_dir)
  end

  def test_file_component_reads_text_file
    markup = "<file src=\"#{@test_file}\">Content</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'This is a test file'
    assert_includes result, 'With multiple lines'
    assert_includes result, 'For testing file component'
  end

  def test_file_component_reads_json_file
    markup = "<file src=\"#{@test_json}\">JSON Content</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'John'
    assert_includes result, '30'
    assert_includes result, 'New York'
  end

  def test_file_component_reads_csv_file
    markup = "<file src=\"#{@test_csv}\">CSV Content</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'name,age,city'
    assert_includes result, 'John,30,New York'
    assert_includes result, 'Jane,25,Boston'
  end

  def test_file_component_with_nonexistent_file
    markup = '<file src="/nonexistent/file.txt">Should handle gracefully</file>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle error gracefully
    assert_includes result, 'file not found'
  end

  def test_file_component_without_src
    markup = '<file>No source specified</file>'
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'no src specified'
  end

  def test_file_component_with_relative_path
    # Test with relative path from current directory
    relative_path = File.join('test', 'fixtures', 'files', 'test.txt')
    markup = "<file src=\"#{relative_path}\">Relative path</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'This is a test file'
  end

  def test_file_component_with_empty_file
    empty_file = File.join(@test_dir, 'empty.txt')
    File.write(empty_file, '')
    
    markup = "<file src=\"#{empty_file}\">Empty file</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle empty file gracefully
    assert_kind_of String, result
  end

  def test_file_component_with_binary_file
    binary_file = File.join(@test_dir, 'binary.bin')
    File.binwrite(binary_file, "\x00\x01\x02\x03")
    
    markup = "<file src=\"#{binary_file}\">Binary file</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle binary file gracefully
    assert_kind_of String, result
  end

  def test_file_component_in_different_formats
    markup = "<file src=\"#{@test_file}\">Test file</file>"
    
    ['raw', 'dict', 'openai_chat'].each do |format|
      result = Poml.process(markup: markup, format: format)
      case format
      when 'openai_chat'
        assert_kind_of Array, result
      when 'dict'
        assert_kind_of Hash, result
      else
        assert_kind_of String, result
        assert_includes result, 'This is a test file'
      end
    end
  end

  def test_file_component_with_large_file
    large_file = File.join(@test_dir, 'large.txt')
    large_content = (1..1000).map { |i| "Line #{i}" }.join("\n")
    File.write(large_file, large_content)
    
    markup = "<file src=\"#{large_file}\">Large file</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should handle large file
    assert_includes result, 'Line 1'
    assert_includes result, 'Line 1000'
  end

  def test_file_component_with_special_characters
    special_file = File.join(@test_dir, 'special.txt')
    File.write(special_file, "Special chars: àáâãäåæçèéêë\n中文\n🚀🌟")
    
    markup = "<file src=\"#{special_file}\">Special chars</file>"
    result = Poml.process(markup: markup, format: 'raw')
    
    assert_includes result, 'Special chars'
    assert_includes result, '中文'
    assert_includes result, '🚀🌟'
  end

  def test_file_component_permissions_error
    # Create a file and then remove read permissions (if possible)
    restricted_file = File.join(@test_dir, 'restricted.txt')
    File.write(restricted_file, 'restricted content')
    
    begin
      File.chmod(0000, restricted_file)
      
      markup = "<file src=\"#{restricted_file}\">Restricted file</file>"
      result = Poml.process(markup: markup, format: 'raw')
      
      # Should handle permission error gracefully
      assert_kind_of String, result
    ensure
      # Restore permissions for cleanup
      File.chmod(0644, restricted_file) rescue nil
    end
  end
end
