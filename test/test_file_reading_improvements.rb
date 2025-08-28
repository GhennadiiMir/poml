require_relative 'test_helper'
require 'tempfile'

class TestFileReadingImprovements < Minitest::Test
  include TestHelper

  def setup
    @test_dir = Dir.mktmpdir('poml_file_test')
  end

  def teardown
    FileUtils.remove_entry(@test_dir) if @test_dir && Dir.exist?(@test_dir)
  end

  def test_utf8_file_reading
    # Create a file with UTF-8 content including international characters
    utf8_content = "Hello 世界! Café naïve résumé 🌍"
    utf8_file = File.join(@test_dir, 'utf8_test.txt')
    File.write(utf8_file, utf8_content, encoding: 'utf-8')

    # Test FileComponent
    markup = "<file src='#{utf8_file}'></file>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    assert_includes result, "Hello 世界!"
    assert_includes result, "Café naïve résumé"
    assert_includes result, "🌍"
  end

  def test_international_filename_support
    # Create files with international characters in filename
    chinese_filename = File.join(@test_dir, '测试文件.txt')
    arabic_filename = File.join(@test_dir, 'ملف_اختبار.txt')
    
    File.write(chinese_filename, "Chinese file content", encoding: 'utf-8')
    File.write(arabic_filename, "Arabic file content", encoding: 'utf-8')

    # Test reading Chinese filename
    markup1 = "<file src='#{chinese_filename}'></file>"
    result1 = Poml.process(markup: markup1, format: 'raw', chat: false)
    assert_includes result1, "Chinese file content"

    # Test reading Arabic filename
    markup2 = "<file src='#{arabic_filename}'></file>"
    result2 = Poml.process(markup: markup2, format: 'raw', chat: false)
    assert_includes result2, "Arabic file content"
  end

  def test_mixed_encoding_graceful_handling
    # Create a file with mixed encoding issues (simulate legacy files)
    mixed_file = File.join(@test_dir, 'mixed_encoding.txt')
    
    # Write content that might cause encoding issues
    content_with_issues = "Normal text\x80\x81Invalid UTF-8\nMore normal text"
    File.write(mixed_file, content_with_issues, mode: 'wb')

    # Should handle gracefully without crashing
    markup = "<file src='#{mixed_file}'></file>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    # Should include the normal text parts
    assert_includes result, "Normal text"
    assert_includes result, "More normal text"
    # Should not crash on invalid UTF-8
    refute_nil result
  end

  def test_json_file_with_utf8_content
    # Create JSON file with international content
    json_data = {
      "name" => "测试用户",
      "city" => "São Paulo", 
      "description" => "Développeur français avec café ☕"
    }
    
    json_file = File.join(@test_dir, 'international.json')
    File.write(json_file, JSON.pretty_generate(json_data), encoding: 'utf-8')

    # Test table component with international JSON
    markup = "<table src='#{json_file}'></table>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    assert_includes result, "测试用户"
    assert_includes result, "São Paulo"
    assert_includes result, "français"
    assert_includes result, "☕"
  end

  def test_jsonl_file_with_utf8_content
    # Create JSONL file with international content
    jsonl_content = [
      '{"id": 1, "text": "Hello 世界"}',
      '{"id": 2, "text": "Café naïve"}',
      '{"id": 3, "text": "Русский текст"}'
    ].join("\n")
    
    jsonl_file = File.join(@test_dir, 'international.jsonl')
    File.write(jsonl_file, jsonl_content, encoding: 'utf-8')

    # Test table component with international JSONL
    markup = "<table src='#{jsonl_file}'></table>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    assert_includes result, "Hello 世界"
    assert_includes result, "Café naïve"
    assert_includes result, "Русский текст"
  end

  def test_folder_component_with_international_files
    # Create subdirectory with international name
    intl_dir = File.join(@test_dir, '国际文件夹')
    Dir.mkdir(intl_dir)
    
    # Create files with various international content
    File.write(File.join(intl_dir, 'español.txt'), "Contenido en español", encoding: 'utf-8')
    File.write(File.join(intl_dir, 'français.txt'), "Contenu en français", encoding: 'utf-8')
    
    # Test folder component
    markup = "<folder src='#{intl_dir}' showContent='true'></folder>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    assert_includes result, "español.txt"
    assert_includes result, "français.txt"
    assert_includes result, "Contenido en español"
    assert_includes result, "Contenu en français"
  end

  def test_document_component_with_utf8
    # Create document with UTF-8 content
    doc_content = "# Document Title\n\nThis document contains:\n- Chinese: 中文内容\n- Arabic: محتوى عربي\n- Emoji: 📄📝"
    doc_file = File.join(@test_dir, 'intl_document.md')
    File.write(doc_file, doc_content, encoding: 'utf-8')

    # Test document component (since DocumentComponent exists in content.rb)
    markup = "<document src='#{doc_file}'></document>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    assert_includes result, "中文内容"
    assert_includes result, "محتوى عربي"
    assert_includes result, "📄📝"
  end

  def test_file_not_found_error_message
    # Test improved error messages
    nonexistent_file = File.join(@test_dir, 'does_not_exist.txt')
    
    markup = "<file src='#{nonexistent_file}'></file>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    assert_includes result, "[File:"
    assert_includes result, "file not found"
    assert_includes result, "does_not_exist.txt"
  end

  def test_encoding_error_handling
    # Create a file that will definitely cause encoding issues
    binary_file = File.join(@test_dir, 'binary_test.bin')
    binary_content = "\x00\x01\x02\x03\xFF\xFE\xFD\xFC"
    File.write(binary_file, binary_content, mode: 'wb')

    # Should handle gracefully
    markup = "<file src='#{binary_file}'></file>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    # Should not crash and provide some content (even if replaced chars)
    refute_nil result
    assert_instance_of String, result
  end

  def test_csv_with_international_content
    # Create CSV with international headers and content
    csv_content = "姓名,城市,描述\n测试用户,北京,软件工程师\nJean Dupont,Paris,Développeur"
    csv_file = File.join(@test_dir, 'international.csv')
    File.write(csv_file, csv_content, encoding: 'utf-8')

    # Test table component with international CSV
    markup = "<table src='#{csv_file}'></table>"
    result = Poml.process(markup: markup, format: 'raw', chat: false)
    
    assert_includes result, "姓名"
    assert_includes result, "测试用户"
    assert_includes result, "北京"
    assert_includes result, "Développeur"
  end

  def test_relative_path_resolution_with_international_names
    # Create subdirectory structure with international names
    sub_dir = File.join(@test_dir, 'उप_निर्देशिका')
    Dir.mkdir(sub_dir)
    
    test_file = File.join(sub_dir, 'परीक्षण.txt')
    File.write(test_file, "International path test", encoding: 'utf-8')
    
    # Create a POML file in the test directory that references the international file
    poml_file = File.join(@test_dir, 'test.poml')
    poml_content = "<file src='उप_निर्देशिका/परीक्षण.txt'></file>"
    File.write(poml_file, poml_content, encoding: 'utf-8')
    
    # Process the POML file itself to test relative resolution
    result = Poml.process(markup: poml_file, format: 'raw', chat: false)
    
    assert_includes result, "International path test"
  end
end
