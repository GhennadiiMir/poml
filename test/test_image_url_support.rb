require_relative 'test_helper'

class TestImageUrlSupport < Minitest::Test
  include TestHelper

  def test_image_with_local_src
    markup = '<poml><img src="test.jpg" alt="Test image" /></poml>'
    
    # Create a temporary image file
    create_temp_image_file('test.jpg')
    
    result = Poml.process(markup: markup)
    
    assert_includes result['content'], '[Image: test.jpg]'
    assert_includes result['content'], '(Test image)'
  ensure
    cleanup_temp_files
  end

  def test_image_with_url_src_mocked
    markup = '<poml><img src="https://example.com/image.jpg" alt="Remote image" /></poml>'
    
    # Mock the HTTP request (unused in current implementation)
    # mock_http_response = create_mock_http_response
    
    # We'll need to test this differently since we can't easily mock in minitest
    # For now, test that it recognizes URLs
    component = create_image_component(markup)
    
    assert component.send(:url?, 'https://example.com/image.jpg')
    refute component.send(:url?, 'local/image.jpg')
    refute component.send(:url?, '/absolute/local/image.jpg')
  end

  def test_image_with_base64_data
    # Small 1x1 PNG image in base64
    base64_png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI9jU77zgAAAABJRU5ErkJggg=='
    
    markup = %(<poml><img base64="#{base64_png}" alt="Base64 image" /></poml>)
    
    result = Poml.process(markup: markup)
    
    # Should process without error
    assert_includes result['content'], '[Image:'
    assert_includes result['content'], '(Base64 image)'
  end

  def test_image_with_missing_src_and_base64
    markup = '<poml><img alt="Missing source" /></poml>'
    
    result = Poml.process(markup: markup)
    
    assert_includes result['content'], '[Image Error: no src or base64 specified]'
  end

  def test_image_syntax_multimedia_vs_text
    markup_multimedia = '<poml><img src="test.jpg" alt="Test" syntax="multimedia" /></poml>'
    markup_text = '<poml><img src="test.jpg" alt="Test" syntax="text" /></poml>'
    
    create_temp_image_file('test.jpg')
    
    result_multimedia = Poml.process(markup: markup_multimedia)
    result_text = Poml.process(markup: markup_text)
    
    # Multimedia mode should show image reference
    assert_includes result_multimedia['content'], '[Image: test.jpg]'
    
    # Text mode should show alt text
    assert_includes result_text['content'], 'Test'
    refute_includes result_text['content'], '[Image:'
  ensure
    cleanup_temp_files
  end

  def test_image_xml_mode
    markup = '<poml syntax="xml"><img src="test.jpg" alt="XML image" /></poml>'
    
    create_temp_image_file('test.jpg')
    
    result = Poml.process(markup: markup)
    
    # Should render as XML
    assert_includes result['content'], '<img'
    assert_includes result['content'], 'src="test.jpg"'
    assert_includes result['content'], 'alt="XML image"'
  ensure
    cleanup_temp_files
  end

  def test_image_type_detection_from_extension
    component = create_image_component('<img src="test.jpg" />')
    
    assert_equal 'image/jpeg', component.send(:detect_image_type_from_extension, 'test.jpg')
    assert_equal 'image/jpeg', component.send(:detect_image_type_from_extension, 'test.jpeg')
    assert_equal 'image/png', component.send(:detect_image_type_from_extension, 'test.png')
    assert_equal 'image/gif', component.send(:detect_image_type_from_extension, 'test.gif')
    assert_equal 'image/webp', component.send(:detect_image_type_from_extension, 'test.webp')
    assert_nil component.send(:detect_image_type_from_extension, 'test.txt')
  end

  def test_image_type_detection_from_magic_bytes
    component = create_image_component('<img src="test.jpg" />')
    
    # JPEG magic bytes
    jpeg_data = "\xFF\xD8\xFF".b
    assert_equal 'image/jpeg', component.send(:detect_image_type, jpeg_data)
    
    # PNG magic bytes
    png_data = "\x89PNG\r\n\x1A\n".b
    assert_equal 'image/png', component.send(:detect_image_type, png_data)
    
    # GIF magic bytes
    gif_data = "GIF87a".b
    assert_equal 'image/gif', component.send(:detect_image_type, gif_data)
    
    # Unknown data
    unknown_data = "unknown".b
    assert_equal 'image/octet-stream', component.send(:detect_image_type, unknown_data)
  end

  def test_image_with_additional_attributes
    markup = '<poml><img src="test.jpg" maxWidth="800" maxHeight="600" resize="0.5" type="png" position="top" /></poml>'
    
    create_temp_image_file('test.jpg')
    
    # Should process without error (even though processing is not fully implemented)
    result = Poml.process(markup: markup)
    
    assert_includes result['content'], '[Image: test.jpg]'
  ensure
    cleanup_temp_files
  end

  def test_image_file_not_found
    markup = '<poml><img src="nonexistent.jpg" alt="Missing file" /></poml>'
    
    result = Poml.process(markup: markup)
    
    assert_includes result['content'], '[Image Error:'
    assert_includes result['content'], 'File not found'
  end

  def test_image_relative_path_resolution
    # Create test directory structure
    temp_dir = create_temp_directory
    image_path = File.join(temp_dir, 'images', 'test.jpg')
    FileUtils.mkdir_p(File.dirname(image_path))
    create_temp_image_file_at(image_path)
    
    # Create a POML file in the temp directory
    poml_file = File.join(temp_dir, 'test.poml')
    File.write(poml_file, '<poml><img src="images/test.jpg" alt="Relative path" /></poml>')
    
    result = Poml.process(markup: poml_file)
    
    assert_includes result['content'], '[Image: images/test.jpg]'
    assert_includes result['content'], '(Relative path)'
  ensure
    cleanup_temp_files
  end

  private

  def create_image_component(markup)
    context = Poml::Context.new
    parsed = Poml::Parser.new(context).parse(markup)
    img_element = find_element_by_tag(parsed, :img)
    Poml::ImageComponent.new(img_element, context)
  end

  def find_element_by_tag(elements, tag)
    elements.each do |element|
      return element if element.tag_name == tag
      found = find_element_by_tag(element.children, tag) if element.children
      return found if found
    end
    nil
  end

  def create_temp_image_file(filename)
    # Create a minimal PNG file (1x1 transparent pixel)
    png_data = [
      "\x89PNG\r\n\x1A\n",  # PNG signature
      "\x00\x00\x00\rIHDR",  # IHDR chunk
      "\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1F\x15\xC4\x89",  # 1x1 RGBA
      "\x00\x00\x00\nIDATx\x9Cc\xF8\x00\x00\x00\x01\x00\x01",  # Minimal IDAT
      "\x02\x1A\xD3\xFF\x00\x00\x00\x00IEND\xAEB`\x82"  # IEND chunk
    ].join.b
    
    File.write(filename, png_data, mode: 'wb')
    @temp_files ||= []
    @temp_files << filename
  end

  def create_temp_image_file_at(path)
    # Same as above but for specific path
    png_data = [
      "\x89PNG\r\n\x1A\n",
      "\x00\x00\x00\rIHDR",
      "\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1F\x15\xC4\x89",
      "\x00\x00\x00\nIDATx\x9Cc\xF8\x00\x00\x00\x01\x00\x01",
      "\x02\x1A\xD3\xFF\x00\x00\x00\x00IEND\xAEB`\x82"
    ].join.b
    
    File.write(path, png_data, mode: 'wb')
    @temp_files ||= []
    @temp_files << path
  end

  def create_temp_directory
    dir = File.join(Dir.tmpdir, "poml_test_#{Process.pid}_#{Time.now.to_i}")
    FileUtils.mkdir_p(dir)
    @temp_files ||= []
    @temp_files << dir
    dir
  end

  def cleanup_temp_files
    return unless @temp_files
    
    @temp_files.each do |file|
      if File.directory?(file)
        FileUtils.rm_rf(file)
      elsif File.exist?(file)
        File.delete(file)
      end
    end
    @temp_files.clear
  end

  def create_mock_http_response
    # This would be used for actual HTTP mocking if we implement it
    {
      code: '200',
      body: "\x89PNG\r\n\x1A\n".b,  # PNG header
      'content-type' => 'image/png'
    }
  end
end
