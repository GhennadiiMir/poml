require "minitest/autorun"
require "poml"

class PomlNewComponentsTest < Minitest::Test
  def test_formatting_components
    # Test basic formatting components
    content = '<poml>
      <bold>Bold text</bold>
      <italic>Italic text</italic>
      <underline>Underlined text</underline>
      <strikethrough>Struck through text</strikethrough>
      <code>puts "hello"</code>
    </poml>'
    
    result = Poml.to_text(content)
    
    assert_includes result, '**Bold text**'
    assert_includes result, '*Italic text*'
    assert_includes result, '<u>Underlined text</u>'
    assert_includes result, '~~Struck through text~~'
    assert_includes result, '`puts "hello"`'
  end
  
  def test_header_component
    content = '<poml>
      <header level="1">Main Header</header>
      <header level="2">Sub Header</header>
      <header level="3">Sub-sub Header</header>
    </poml>'
    
    result = Poml.to_text(content)
    
    assert_includes result, '# Main Header'
    assert_includes result, '## Sub Header'
    assert_includes result, '### Sub-sub Header'
  end
  
  def test_newline_component
    content = '<poml>
      First line<newline/>Second line<newline newLineCount="2"/>Third line
    </poml>'
    
    result = Poml.to_text(content)
    
    assert_includes result, "First line\nSecond line\n\nThird line"
  end
  
  def test_media_components
    content = '<poml>
      <audio src="test.mp3">Audio description</audio>
    </poml>'
    
    result = Poml.to_text(content)
    assert_includes result, '[Audio: test.mp3]'
  end
  
  def test_chat_components
    content = '<poml>
      <system>You are a helpful assistant.</system>
      <human>Hello world!</human>
      <ai>Hi there!</ai>
    </poml>'
    
    chat_result = Poml.to_chat(content)
    
    assert_kind_of Array, chat_result
    assert_equal 3, chat_result.length
    
    # Check system message
    system_msg = chat_result.find { |msg| msg['role'] == 'system' }
    refute_nil system_msg
    assert_includes system_msg['content'], 'helpful assistant'
    
    # Check user message
    user_msg = chat_result.find { |msg| msg['role'] == 'user' }
    assert_not_nil user_msg
    assert_includes user_msg['content'], 'Hello world'
    
    # Check assistant message
    assistant_msg = chat_result.find { |msg| msg['role'] == 'assistant' }
    assert_not_nil assistant_msg
    assert_includes assistant_msg['content'], 'Hi there'
  end
  
  def test_conversation_component
    content = '<poml>
      <conversation>
        <ai>What can I help you with?</ai>
        <human>I need help with Ruby.</human>
        <ai>I\'d be happy to help with Ruby!</ai>
      </conversation>
    </poml>'
    
    result = Poml.to_text(content)
    
    assert_includes result, 'What can I help you with?'
    assert_includes result, 'I need help with Ruby'
    assert_includes result, 'happy to help with Ruby'
  end
  
  def test_template_variables
    content = '<poml>
      <human>Hello {{name}}, your task is {{task}}!</human>
    </poml>'
    
    result = Poml.to_text(content, variables: { name: 'Alice', task: 'code review' })
    
    assert_includes result, 'Hello Alice'
    assert_includes result, 'code review'
    refute_includes result, '{{name}}'
    refute_includes result, '{{task}}'
  end
  
  def test_if_component
    content = '<poml>
      <if condition="show_greeting">
        <human>Hello there!</human>
      </if>
      <if condition="show_farewell">
        <human>Goodbye!</human>
      </if>
    </poml>'
    
    # Test with greeting enabled
    result = Poml.to_text(content, variables: { show_greeting: true, show_farewell: false })
    assert_includes result, 'Hello there!'
    refute_includes result, 'Goodbye!'
    
    # Test with farewell enabled  
    result = Poml.to_text(content, variables: { show_greeting: false, show_farewell: true })
    refute_includes result, 'Hello there!'
    assert_includes result, 'Goodbye!'
    
    # Test with both disabled
    result = Poml.to_text(content, variables: { show_greeting: false, show_farewell: false })
    refute_includes result, 'Hello there!'
    refute_includes result, 'Goodbye!'
  end
  
  def test_for_component
    content = '<poml>
      <for variable="item" items="items">
        <human>Item: {{item}}</human>
      </for>
    </poml>'
    
    result = Poml.to_text(content, variables: { items: ['apple', 'banana', 'cherry'] })
    
    assert_includes result, 'Item: apple'
    assert_includes result, 'Item: banana'
    assert_includes result, 'Item: cherry'
    refute_includes result, '{{item}}'
  end
  
  def test_meta_component_response_schema
    content = '<poml>
      <meta type="response_schema">{"type": "object", "properties": {"answer": {"type": "string"}}}</meta>
      <human>What is 2+2?</human>
    </poml>'
    
    result = Poml.to_dict(content)
    
    assert result.key?('metadata')
    assert result['metadata'].key?('response_schema')
    assert_equal 'object', result['metadata']['response_schema']['type']
    assert result['metadata']['response_schema']['properties'].key?('answer')
  end
  
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
    
    assert result.key?('metadata')
    assert result['metadata'].key?('tools')
    assert_equal 1, result['metadata']['tools'].length
    
    tool = result['metadata']['tools'].first
    assert_equal 'calculator', tool['name']
    assert_includes tool['description'], 'arithmetic'
  end
  
  def test_complex_template_with_nested_conditions
    content = '<poml>
      <if condition="show_intro">
        <human>Hello {{user_name}}!</human>
        <if condition="show_role">
          <system>You are a {{role}} assistant.</system>
        </if>
      </if>
      <for variable="task" items="tasks">
        <human>Task {{loop.index}}: {{task}}</human>
      </for>
    </poml>'
    
    variables = {
      show_intro: true,
      show_role: true,
      user_name: 'Bob',
      role: 'helpful',
      tasks: ['review code', 'write tests', 'deploy app']
    }
    
    result = Poml.to_text(content, variables: variables)
    
    assert_includes result, 'Hello Bob!'
    assert_includes result, 'helpful assistant'
    assert_includes result, 'Task 1: review code'
    assert_includes result, 'Task 2: write tests'
    assert_includes result, 'Task 3: deploy app'
  end
  
  def test_folder_component
    # Create a temporary directory structure for testing
    require 'tmpdir'
    require 'fileutils'
    
    Dir.mktmpdir do |tmpdir|
      # Create test files
      File.write(File.join(tmpdir, 'file1.txt'), 'Content of file 1')
      File.write(File.join(tmpdir, 'file2.rb'), 'puts "hello"')
      
      subdir = File.join(tmpdir, 'subdir')
      Dir.mkdir(subdir)
      File.write(File.join(subdir, 'file3.py'), 'print("hello")')
      
      content = %(<poml>
        <folder src="#{tmpdir}"/>
      </poml>)
      
      result = Poml.to_text(content)
      
      assert_includes result, 'file1.txt'
      assert_includes result, 'file2.rb'
      assert_includes result, 'Content of file 1'
      assert_includes result, 'puts "hello"'
    end
  end
  
  def test_tree_component
    require 'tmpdir'
    require 'fileutils'
    
    Dir.mktmpdir do |tmpdir|
      # Create test directory structure
      File.write(File.join(tmpdir, 'readme.md'), '# Test Project')
      
      src_dir = File.join(tmpdir, 'src')
      Dir.mkdir(src_dir)
      File.write(File.join(src_dir, 'main.rb'), 'puts "main"')
      
      content = %(<poml>
        <tree src="#{tmpdir}"/>
      </poml>)
      
      result = Poml.to_text(content)
      
      assert_includes result, 'readme.md'
      assert_includes result, 'src/'
      assert_includes result, 'main.rb'
    end
  end
  
  def test_mixed_formatting_and_logic
    content = '<poml>
      <if condition="use_bold">
        <bold>This is important: {{message}}</bold>
      </if>
      <if condition="use_code">
        <code>{{code_snippet}}</code>
      </if>
    </poml>'
    
    variables = {
      use_bold: true,
      use_code: false,
      message: 'Hello World',
      code_snippet: 'puts "test"'
    }
    
    result = Poml.to_text(content, variables: variables)
    
    assert_includes result, '**This is important: Hello World**'
    refute_includes result, '`puts "test"`'
    refute_includes result, '{{message}}'
  end
end
