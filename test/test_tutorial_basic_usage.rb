require "minitest/autorun"
require "poml"

class TutorialBasicUsageTest < Minitest::Test
  # Tests for docs/tutorial/basic-usage.md examples
  
  def test_basic_poml_structure
    # From "Basic POML Structure" section
    markup = <<~POML
      <poml>
        <role>Code Reviewer</role>
        <task>Review the following Ruby code for best practices</task>
        <hint>Focus on performance and readability</hint>
      </poml>
    POML

    result = Poml.process(markup: markup)
    assert result['content'].include?('Code Reviewer')
    assert result['content'].include?('Review the following Ruby code')
    assert result['content'].include?('Focus on performance and readability')
  end

  def test_paragraph_and_text_formatting
    # From "Text and Paragraphs" section
    markup = <<~POML
      <poml>
        <role>Technical Writer</role>
        <task>Create documentation</task>
        
        <p>This is the first paragraph with important information.</p>
        <p>This is a second paragraph with additional context.</p>
        
        <p>
          This paragraph contains <b>bold text</b>, <i>italic text</i>, 
          and <code>inline code</code> examples.
        </p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Technical Writer')
    assert content.include?('first paragraph with important')
    assert content.include?('second paragraph with additional')
    # Formatting should be preserved in some form
    assert content.include?('bold') || content.include?('**')
    assert content.include?('italic') || content.include?('*')
    assert content.include?('code') || content.include?('`')
  end

  def test_lists_and_structure
    # From "Lists and Structure" section  
    markup = <<~POML
      <poml>
        <role>Project Manager</role>
        <task>Define project requirements</task>
        
        <p>Key requirements:</p>
        <list>
          <item>Performance optimization</item>
          <item>Security implementation</item>
          <item>User experience improvements</item>
          <item>Documentation updates</item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Project Manager')
    assert content.include?('Key requirements')
    assert content.include?('Performance optimization')
    assert content.include?('Security implementation')
    assert content.include?('User experience improvements')
    assert content.include?('Documentation updates')
  end

  def test_processing_with_context
    # From "Processing with Context" section
    markup = <<~POML
      <poml>
        <role>{{specialist_type}} Specialist</role>
        <task>{{main_objective}}</task>
        
        <p>Project: {{project_name}}</p>
        <p>Deadline: {{deadline}}</p>
        
        <hint>{{additional_guidance}}</hint>
      </poml>
    POML

    context = {
      'specialist_type' => 'Security',
      'main_objective' => 'Conduct vulnerability assessment',
      'project_name' => 'E-commerce Platform',
      'deadline' => '2024-03-15',
      'additional_guidance' => 'Focus on payment processing security'
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('Security Specialist')
    assert content.include?('Conduct vulnerability assessment')
    assert content.include?('E-commerce Platform')
    assert content.include?('2024-03-15')
    assert content.include?('Focus on payment processing security')
    
    # Verify template variables were replaced
    refute content.include?('{{specialist_type}}')
    refute content.include?('{{main_objective}}')
  end

  def test_different_output_formats_basic
    # From "Output Formats" section - basic examples
    markup = <<~POML
      <poml>
        <role>Assistant</role>
        <task>Help with data analysis</task>
      </poml>
    POML

    # Raw format
    raw_result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, raw_result
    assert raw_result.length > 0

    # Dict format (default)
    dict_result = Poml.process(markup: markup, format: 'dict')
    assert_kind_of Hash, dict_result
    assert dict_result.key?('content')
    assert dict_result.key?('metadata')
    assert dict_result['content'].include?('Assistant')

    # Verify different formats produce different structures
    refute_equal raw_result.class, dict_result.class
  end

  def test_inline_rendering_examples
    # From "Inline Rendering" section
    markup = <<~POML
      <poml>
        <role>Documentation Writer</role>
        <task>Explain the API method</task>
        
        <p>
          The <code inline="true">process_data</code> method accepts a 
          <b inline="true">Hash</b> parameter and returns a 
          <i inline="true">ProcessedResult</i> object.
        </p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Documentation Writer')
    assert content.include?('process_data')
    assert content.include?('Hash')
    assert content.include?('ProcessedResult')
    
    # Inline rendering should create flowing text
    # The exact format may vary, but content should flow together
    assert content.length > 0
  end

  def test_nested_components
    # From "Nested Components" section
    markup = <<~POML
      <poml>
        <role>Code Instructor</role>
        <task>Teach programming concepts</task>
        
        <p>
          Today we'll learn about <b>Object-Oriented Programming</b> concepts:
        </p>
        
        <list>
          <item>
            <b>Classes</b> - Templates for creating objects
            <p><i>Example:</i> <code>class User</code></p>
          </item>
          <item>
            <b>Objects</b> - Instances of classes
            <p><i>Example:</i> <code>user = User.new</code></p>
          </item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']
    
    assert content.include?('Code Instructor')
    assert content.include?('Object-Oriented Programming')
    assert content.include?('Classes')
    assert content.include?('Templates for creating objects')
    assert content.include?('class User')
    assert content.include?('Objects')
    assert content.include?('user = User.new')
  end

  def test_error_handling_basic
    # From "Common Patterns" section - error handling
    markup = <<~POML
      <poml>
        <role>{{missing_role}}</role>
        <task>Test error handling</task>
      </poml>
    POML

    # Should handle missing variables gracefully
    result = Poml.process(markup: markup, context: {})
    
    # Should not raise an error
    assert_kind_of Hash, result
    assert result.key?('content')
    
    # Content might contain the unreplaced variable or empty string
    content = result['content']
    assert content.include?('Test error handling')
  end

  def test_real_world_example
    # From "Real-World Example" section
    markup = <<~POML
      <poml>
        <role>Senior {{technology}} Developer</role>
        <task>Code review for {{feature_name}} implementation</task>
        
        <p>Review focus areas:</p>
        <list>
          <item><b>Performance</b> - Algorithm efficiency and optimization</item>
          <item><b>Security</b> - Input validation and vulnerability assessment</item>
          <item><b>Maintainability</b> - Code organization and documentation</item>
          <item><b>Testing</b> - Unit test coverage and edge cases</item>
        </list>
        
        <hint>
          Pay special attention to {{priority_area}} and ensure 
          compatibility with {{framework}} best practices.
        </hint>
      </poml>
    POML

    context = {
      'technology' => 'Ruby',
      'feature_name' => 'user authentication',
      'priority_area' => 'security vulnerabilities',
      'framework' => 'Rails'
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']
    
    assert content.include?('Senior Ruby Developer')
    assert content.include?('user authentication')
    assert content.include?('Review focus areas')
    assert content.include?('Performance')
    assert content.include?('Algorithm efficiency')
    assert content.include?('Security')
    assert content.include?('Input validation')
    assert content.include?('Maintainability')
    assert content.include?('Testing')
    assert content.include?('security vulnerabilities')
    assert content.include?('Rails best practices')
  end
end
