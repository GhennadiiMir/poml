require "minitest/autorun"
require "poml"
require "json"
require "tempfile"

class PomlTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Poml::VERSION
  end

  def test_basic_functionality
    # Test basic POML processing
    simple_poml = "<poml><role>You are a helpful assistant.</role><task>Say hello.</task></poml>"
    
    result = Poml.process(markup: simple_poml, format: 'dict')
    assert_kind_of Hash, result
    assert result.key?('content')
    refute_empty result['content']
  end
  
  def test_file_processing
    # Test that we can process an actual POML file
    examples_dir = File.expand_path("../examples", __dir__)
    simple_example = File.join(examples_dir, "102_render_xml.poml")
    
    # Skip if example doesn't exist
    return unless File.exist?(simple_example)
    
    result = Poml.process(markup: simple_example, format: 'raw')
    assert_kind_of String, result
    refute_empty result
  end

  # Test all output formats
  def test_output_formats
    markup = '<poml><role>Assistant</role><task>Help users</task></poml>'
    
    # Test raw format
    result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, result
    assert_includes result, 'Assistant'
    assert_includes result, 'Help users'
    
    # Test dict format (default)
    result = Poml.process(markup: markup, format: 'dict')
    assert_kind_of Hash, result
    assert result.key?('content')
    assert result.key?('metadata')
    assert_kind_of Hash, result['metadata']
    
    # Test openai_chat format
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, result
    assert result.length > 0
    assert result.first.key?('role')
    assert result.first.key?('content')
    
    # Test langchain format
    result = Poml.process(markup: markup, format: 'langchain')
    assert_kind_of Hash, result
    assert result.key?('messages')
    assert result.key?('content')
    assert_kind_of Array, result['messages']
    
    # Test pydantic format
    result = Poml.process(markup: markup, format: 'pydantic')
    assert_kind_of Hash, result
    assert result.key?('content')  # Pydantic format uses 'content' key, not 'prompt'
    assert result.key?('variables')
    assert result.key?('chat_enabled')
  end

  def test_template_variables
    markup = '<poml><role>{{expert_type}} Expert</role><task>{{main_task}}</task></poml>'
    context = {
      'expert_type' => 'Ruby',
      'main_task' => 'Debug code'
    }
    
    result = Poml.process(markup: markup, context: context, format: 'raw')
    assert_includes result, 'Ruby Expert'
    assert_includes result, 'Debug code'
    
    # Test with dict format to verify context is preserved
    result = Poml.process(markup: markup, context: context, format: 'dict')
    assert_equal context, result['metadata']['variables']
  end

  def test_complex_markup_with_components
    markup = <<~POML
      <poml>
        <role>Technical Writer</role>
        <task>Create documentation</task>
        
        <p>Write documentation for these endpoints:</p>
        
        <list>
          <item>GET /users - Retrieve user list</item>
          <item>POST /users - Create new user</item>
        </list>
        
        <hint>Include examples and error handling</hint>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Technical Writer'
    assert_includes result, 'Create documentation'
    assert_includes result, 'GET /users'
    assert_includes result, 'POST /users'
    assert_includes result, 'Include examples'
  end

  def test_stylesheets
    markup = '<poml><role>API Writer</role><cp caption="Authentication"><p>All requests need auth.</p></cp></poml>'
    
    # Test without stylesheet
    result_plain = Poml.process(markup: markup, format: 'raw')
    
    # Test with stylesheet
    stylesheet = {
      'cp' => { 'captionStyle' => 'header' },
      'role' => { 'captionStyle' => 'bold' }
    }
    result_styled = Poml.process(markup: markup, stylesheet: stylesheet, format: 'raw')
    
    # Both should contain the core content
    assert_includes result_plain, 'API Writer'
    assert_includes result_styled, 'API Writer'
    assert_includes result_plain, 'Authentication'
    assert_includes result_styled, 'Authentication'
  end

  def test_chat_mode_toggle
    markup = '<poml><role>Assistant</role><task>Help users</task></poml>'
    
    # Test with chat mode enabled (default)
    result_chat = Poml.process(markup: markup, chat: true, format: 'dict')
    assert_equal true, result_chat['metadata']['chat']
    
    # Test with chat mode disabled
    result_no_chat = Poml.process(markup: markup, chat: false, format: 'dict')
    assert_equal false, result_no_chat['metadata']['chat']
  end

  def test_xml_syntax_mode
    markup = <<~POML
      <poml syntax="xml">
        <role>System Architect</role>
        <cp caption="Requirements">
          <list>
            <item>Scalability</item>
            <item>Performance</item>
          </list>
        </cp>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'System Architect'
    assert_includes result, 'Requirements'
    assert_includes result, 'Scalability'
    assert_includes result, 'Performance'
  end

  def test_examples_component
    markup = <<~POML
      <poml>
        <role>Code Generator</role>
        <task>Generate Ruby code</task>
        
        <example>
          <input>Create a User class</input>
          <output>class User; end</output>
        </example>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Code Generator'
    assert_includes result, 'Create a User class'
    assert_includes result, 'class User; end'
  end

  def test_error_handling
    # Test invalid format
    markup = '<poml><role>Test</role><task>Test</task></poml>'
    
    assert_raises(Poml::Error) do
      Poml.process(markup: markup, format: 'invalid_format')
    end
    
    # Test malformed markup (should not crash)
    malformed_markup = '<poml><role>Test</role><unclosed_tag>Content'
    
    # This should either work or raise a Poml::Error, but not crash
    begin
      result = Poml.process(markup: malformed_markup)
      # If it doesn't raise an error, that's fine too
    rescue Poml::Error
      # Expected behavior for malformed markup
    end
  end

  def test_file_input_and_output
    # Test file input
    Tempfile.create(['test_input', '.poml']) do |input_file|
      markup_content = '<poml><role>File Test</role><task>Process from file</task></poml>'
      input_file.write(markup_content)
      input_file.flush
      
      result = Poml.process(markup: input_file.path, format: 'raw')
      assert_includes result, 'File Test'
      assert_includes result, 'Process from file'
    end
    
    # Test file output
    Tempfile.create(['test_output', '.txt']) do |output_file|
      markup = '<poml><role>Output Test</role><task>Save to file</task></poml>'
      
      Poml.process(markup: markup, output_file: output_file.path, format: 'raw')
      
      output_content = File.read(output_file.path)
      assert_includes output_content, 'Output Test'
      assert_includes output_content, 'Save to file'
    end
  end

  def test_integration_patterns
    # Test service class pattern
    service_class = Class.new do
      def self.generate(template_name, context = {})
        markup = "<poml><role>Service Test</role><task>#{template_name}</task></poml>"
        Poml.process(markup: markup, context: context, format: 'raw')
      end
    end
    
    result = service_class.generate('Test Task', {'var' => 'value'})
    assert_includes result, 'Service Test'
    assert_includes result, 'Test Task'
    
    # Test error handling pattern
    error_caught = false
    begin
      Poml.process(markup: '<invalid>', format: 'invalid')
    rescue Poml::Error => e
      error_caught = true
      assert_kind_of String, e.message
    end
    assert error_caught, "Expected Poml::Error to be raised"
  end

  def test_conditional_content_with_context
    markup = <<~POML
      <poml>
        <role>{{role_type}}</role>
        <task>{{task_description}}</task>
        
        <p>Base content always present</p>
        
        <hint>{{#priority}}High priority: {{priority}}{{/priority}}</hint>
      </poml>
    POML
    
    # Test with priority
    context_with_priority = {
      'role_type' => 'Manager',
      'task_description' => 'Manage project',
      'priority' => 'URGENT'
    }
    
    result = Poml.process(markup: markup, context: context_with_priority, format: 'raw')
    assert_includes result, 'Manager'
    assert_includes result, 'Manage project'
    assert_includes result, 'Base content always present'
    
    # Test without priority
    context_no_priority = {
      'role_type' => 'Developer',
      'task_description' => 'Write code'
    }
    
    result = Poml.process(markup: markup, context: context_no_priority, format: 'raw')
    assert_includes result, 'Developer'
    assert_includes result, 'Write code'
    assert_includes result, 'Base content always present'
  end

  def test_openai_integration_format
    markup = '<poml><role>AI Assistant</role><task>Help with coding</task></poml>'
    messages = Poml.process(markup: markup, format: 'openai_chat')
    
    # Verify OpenAI API compatible structure
    assert_kind_of Array, messages
    messages.each do |message|
      assert message.key?('role')
      assert message.key?('content')
      assert_includes ['system', 'user', 'assistant'], message['role']
      assert_kind_of String, message['content']
    end
    
    # Test that it could be used in an API call structure
    api_payload = {
      model: 'gpt-4',
      messages: messages,
      max_tokens: 1000
    }
    
    assert_kind_of Hash, api_payload
    assert_equal messages, api_payload[:messages]
  end

  def test_performance_basic
    markup = '<poml><role>Performance Test</role><task>Measure processing time</task></poml>'
    
    # Measure processing time for basic operation
    start_time = Time.now
    100.times do
      Poml.process(markup: markup, format: 'dict')
    end
    end_time = Time.now
    
    processing_time = end_time - start_time
    
    # Should process 100 simple operations in under 5 seconds
    assert processing_time < 5.0, "Processing 100 operations took #{processing_time} seconds, expected < 5.0"
  end

  def test_all_tutorial_examples_work
    # This test ensures that key patterns from the tutorial actually work
    
    # Basic usage pattern
    markup = '<poml><role>Assistant</role><task>Help users with questions</task></poml>'
    result = Poml.process(markup: markup)
    assert result['content'].include?('Assistant')
    
    # Template variables pattern
    markup = '<poml><role>{{role_name}}</role><task>{{task_name}}</task></poml>'
    context = { 'role_name' => 'Data Analyst', 'task_name' => 'Analyze data' }
    result = Poml.process(markup: markup, context: context)
    assert result['content'].include?('Data Analyst')
    
    # All format patterns
    ['raw', 'dict', 'openai_chat', 'langchain', 'pydantic'].each do |format|
      result = Poml.process(markup: markup, context: context, format: format)
      refute_nil result
      case format
      when 'raw'
        assert_kind_of String, result
      when 'dict'
        assert_kind_of Hash, result
        assert result.key?('content')
      when 'openai_chat'
        assert_kind_of Array, result
      when 'langchain'
        assert_kind_of Hash, result
        assert result.key?('messages')
      when 'pydantic'
        assert_kind_of Hash, result
        assert result.key?('content')  # Pydantic format uses 'content' key, not 'prompt'
      end
    end
    
    # Stylesheet pattern
    markup = '<poml><role>API Writer</role><cp caption="Auth"><p>Requires authentication.</p></cp></poml>'
    stylesheet = { 'cp' => { 'captionStyle' => 'header' } }
    result = Poml.process(markup: markup, stylesheet: stylesheet)
    assert result['content'].include?('API Writer')
    
    # Chat mode toggle
    result_chat = Poml.process(markup: markup, chat: true, format: 'dict')
    result_no_chat = Poml.process(markup: markup, chat: false, format: 'dict')
    assert_equal true, result_chat['metadata']['chat']
    assert_equal false, result_no_chat['metadata']['chat']
  end

  # Test advanced template features implemented
  def test_for_loop_with_arrays
    # Test numeric arrays
    markup = '<for variable="i" items="[1,2,3]">Item: {{i}} </for>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Item: 1'
    assert_includes result, 'Item: 2'
    assert_includes result, 'Item: 3'
    
    # Test string arrays
    markup = '<for variable="item" items="[\"apple\", \"banana\"]">Fruit: {{item}} </for>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Fruit: apple'
    assert_includes result, 'Fruit: banana'
  end

  def test_for_loop_with_index
    markup = '<for variable="item" items="[\"a\",\"b\",\"c\"]">{{loop.index}}: {{item}} </for>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '1: a'
    assert_includes result, '2: b'
    assert_includes result, '3: c'
  end

  def test_conditional_comparisons
    # Test numeric comparisons
    markup = '<if condition="5 > 3">Greater than works</if>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Greater than works'
    
    markup = '<if condition="2 < 1">Should not show</if>'
    result = Poml.process(markup: markup, format: 'raw')
    refute_includes result, 'Should not show'
    
    # Test equality
    markup = '<if condition="1 == 1">Equal works</if>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Equal works'
    
    # Test string equality
    markup = '<if condition="\"hello\" == \"hello\"">String equal works</if>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'String equal works'
  end

  def test_nested_templates
    markup = '<for variable="item" items="[1,2,3,4,5]"><if condition="{{item}} > 3">Item {{item}} is greater than 3. </if></for>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Item 4 is greater than 3'
    assert_includes result, 'Item 5 is greater than 3'
    refute_includes result, 'Item 1 is greater than 3'
    refute_includes result, 'Item 2 is greater than 3'
  end

  def test_chat_components
    markup = '<ai>Hello from AI</ai><human>Hello from human</human><system>Be helpful</system>'
    
    # Test OpenAI chat format
    result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, result
    assert_equal 3, result.length
    
    assert_equal 'assistant', result[0]['role']
    assert_equal 'Hello from AI', result[0]['content']
    
    assert_equal 'user', result[1]['role'] 
    assert_equal 'Hello from human', result[1]['content']
    
    assert_equal 'system', result[2]['role']
    assert_equal 'Be helpful', result[2]['content']
    
    # Test that raw format shows empty content (messages are structured)
    result = Poml.process(markup: markup, format: 'raw')
    refute_includes result, 'Hello from AI'
  end

  def test_meta_component_with_custom_metadata
    markup = '<meta title="Test Document" description="A test document" author="Test Author">Content</meta>'
    result = Poml.process(markup: markup, format: 'dict')
    
    assert_equal 'Test Document', result['metadata']['title']
    assert_equal 'A test document', result['metadata']['description']
    assert_equal 'Test Author', result['metadata']['author']
  end

  def test_table_component_with_json_data
    markup = '<table records="[{\"name\": \"John\", \"age\": 30}, {\"name\": \"Jane\", \"age\": 25}]">Table</table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should render as markdown table
    assert_includes result, '| name | age |'
    assert_includes result, 'John'
    assert_includes result, '30'
    assert_includes result, 'Jane'
    assert_includes result, '25'
  end

  def test_table_component_with_html_markup
    markup = '<table><tr><td>Name</td><td>Age</td></tr><tr><td>John</td><td>30</td></tr></table>'
    result = Poml.process(markup: markup, format: 'raw')
    
    # Should render as markdown table
    assert_includes result, '| Column 1 | Column 2 |'
    assert_includes result, 'Name'
    assert_includes result, 'Age'
    assert_includes result, 'John'
    assert_includes result, '30'
  end

  def test_utility_components
    # Test folder component
    markup = '<folder src="lib" maxDepth="1">Folder content</folder>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'poml.rb'
    
    # Test tree component with items
    markup = '<tree items="[{\"name\": \"root\", \"children\": [{\"name\": \"child1\"}, {\"name\": \"child2\"}]}]">Tree</tree>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'root'
    assert_includes result, 'child1'
    assert_includes result, 'child2'
    
    # Test conversation component with messages
    markup = '<conversation messages="[{\"speaker\": \"human\", \"content\": \"Hi\"}, {\"speaker\": \"ai\", \"content\": \"Hello\"}]">Conversation</conversation>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Human:'
    assert_includes result, 'Hi'
    assert_includes result, 'Hello'
  end

  def test_formatting_components
    # Test bold, italic, underline
    markup = '<b>bold</b> <i>italic</i> <u>underline</u>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**bold**'
    assert_includes result, '*italic*'
    assert_includes result, '__underline__'
    
    # Test nested formatting
    markup = '<b>Bold with <i>italic</i> inside</b>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '**Bold with *italic* inside**'
  end

  def test_list_components
    markup = '<list><item>First item</item><item>Second item</item></list>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '- First item'
    assert_includes result, '- Second item'
  end

  def test_example_components
    markup = '<examples><example><input>Hello</input><output>Hi there!</output></example></examples>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Examples'
    assert_includes result, 'Hello'
    assert_includes result, 'Hi there!'
  end

  def test_json_attribute_parsing
    # Test that JSON arrays are parsed correctly in attributes
    markup = '<for variable="x" items="[10, 20, 30]">Value: {{x}} </for>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Value: 10'
    assert_includes result, 'Value: 20'
    assert_includes result, 'Value: 30'
  end

  def test_complex_template_expressions
    # Test template variable substitution in conditions
    markup = '<for variable="num" items="[1,5,10]"><if condition="{{num}} >= 5">{{num}} is at least 5. </if></for>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, '5 is at least 5'
    assert_includes result, '10 is at least 5'
    refute_includes result, '1 is at least 5'
  end

  def test_error_handling_and_edge_cases
    # Test unknown components are handled gracefully
    markup = '<unknowncomponent>Content</unknowncomponent>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'unknowncomponent'
    assert_includes result, 'Content'
    
    # Test empty attributes
    markup = '<for variable="" items="">Empty</for>'
    result = Poml.process(markup: markup, format: 'raw')
    # Should not crash and return something reasonable
    assert_kind_of String, result
    
    # Test malformed JSON in attributes
    markup = '<tree items="[malformed">Tree</tree>'
    result = Poml.process(markup: markup, format: 'raw')
    # Should not crash
    assert_kind_of String, result
  end

  def test_variable_substitution_in_meta
    markup = '<meta variables="{\"name\": \"Alice\"}"><p>Hello {{name}}!</p></meta>'
    result = Poml.process(markup: markup, format: 'raw')
    assert_includes result, 'Hello Alice!'
  end

  def test_multiple_output_formats_consistency
    markup = '<ai>Test message</ai><human>User message</human>'
    
    # Test raw format
    raw_result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, raw_result
    
    # Test dict format
    dict_result = Poml.process(markup: markup, format: 'dict')
    assert_kind_of Hash, dict_result
    assert dict_result.key?('content')
    assert dict_result.key?('metadata')
    
    # Test openai_chat format
    chat_result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, chat_result
    assert_equal 2, chat_result.length
    assert_equal 'assistant', chat_result[0]['role']
    assert_equal 'user', chat_result[1]['role']
  end

  def test_performance_with_large_loops
    # Test performance doesn't degrade significantly with larger loops
    markup = '<for variable="i" items="' + (1..100).to_a.to_s + '">{{i}} </for>'
    
    start_time = Time.now
    result = Poml.process(markup: markup, format: 'raw')
    end_time = Time.now
    
    # Should complete within reasonable time (less than 1 second)
    assert (end_time - start_time) < 1.0, "Large loop took too long: #{end_time - start_time} seconds"
    assert_includes result, '1 '
    assert_includes result, '100'  # Last item doesn't have trailing space, which is correct
  end
end
