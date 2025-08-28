require "minitest/autorun"
require "poml"
require "json"
require "tempfile"

class TutorialExamplesTest < Minitest::Test
  # Tests that verify all examples from the tutorial documentation work correctly
  # Note: Tutorial moved to docs/tutorial/ structure for better organization
  
  def test_basic_usage_examples
    # From "Basic Usage" section
    
    # Simple prompt creation
    markup = '<poml><role>Assistant</role><task>Help users with questions</task></poml>'
    result = Poml.process(markup: markup)
    assert result['content'].include?('Assistant')
    assert result['content'].include?('Help users with questions')
    
    # Adding hints and context
    markup = <<~POML
      <poml>
        <role>Expert Data Scientist</role>
        <task>Analyze the provided dataset and identify trends</task>
        <hint>Focus on seasonal patterns and anomalies</hint>
        <p>Please provide detailed insights with visualizations.</p>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    assert result['content'].include?('Expert Data Scientist')
    assert result['content'].include?('seasonal patterns')
    assert result['content'].include?('visualizations')
  end

  def test_output_format_examples
    markup = '<poml><role>Assistant</role><task>Summarize this text</task></poml>'
    
    # Raw format example
    result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, result
    assert result.include?('===== system =====') || result.include?('Assistant')
    
    # Dictionary format example
    result = Poml.process(markup: markup, format: 'dict')
    assert_kind_of Hash, result
    assert result.key?('content')
    assert result.key?('metadata')
    assert_equal true, result['metadata']['chat']
    
    # OpenAI Chat format example
    messages = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, messages
    assert messages.first.key?('role')
    assert messages.first.key?('content')
    
    # LangChain format example
    result = Poml.process(markup: markup, format: 'langchain')
    assert_kind_of Hash, result
    assert result.key?('messages')
    assert result.key?('content')
    
    # Pydantic format example
    result = Poml.process(markup: markup, format: 'pydantic')
    assert_kind_of Hash, result
    assert result.key?('content')  # Pydantic format uses 'content' key, not 'prompt'
    assert result.key?('variables')
    assert result.key?('chat_enabled')
  end

  def test_template_variables_examples
    # Basic variable substitution
    markup = <<~POML
      <poml>
        <role>{{expert_type}} Expert</role>
        <task>{{main_task}}</task>
        <hint>Focus on {{focus_area}} and provide {{output_type}}</hint>
      </poml>
    POML
    
    context = {
      'expert_type' => 'Machine Learning',
      'main_task' => 'Analyze model performance',
      'focus_area' => 'accuracy metrics',
      'output_type' => 'actionable recommendations'
    }
    
    result = Poml.process(markup: markup, context: context)
    assert result['content'].include?('Machine Learning Expert')
    assert result['content'].include?('Analyze model performance')
    assert result['content'].include?('accuracy metrics')
    assert result['content'].include?('actionable recommendations')
  end

  def test_dynamic_content_creation
    def create_code_review_prompt(language, complexity, focus_areas)
      markup = <<~POML
        <poml>
          <role>Senior {{language}} Developer</role>
          <task>Review the following {{language}} code</task>
          
          <p>Code complexity level: {{complexity}}</p>
          
          <p>Please focus on:</p>
          <list>
            <item>Performance</item>
            <item>Readability</item>
            <item>Security</item>
          </list>
          
          <hint>Provide specific suggestions for improvement</hint>
        </poml>
      POML
      
      context = {
        'language' => language,
        'complexity' => complexity
      }
      
      Poml.process(markup: markup, context: context, format: 'raw')
    end
    
    prompt = create_code_review_prompt('Ruby', 'Intermediate', ['Performance', 'Readability'])
    assert prompt.include?('Senior Ruby Developer')
    assert prompt.include?('Intermediate')
    assert prompt.include?('Performance')
    assert prompt.include?('Readability')
  end

  def test_stylesheet_examples
    markup = <<~POML
      <poml>
        <role>API Documentation Writer</role>
        <task>Document REST endpoints</task>
        
        <cp caption="Authentication">
          <p>All requests require authentication via API key.</p>
        </cp>
        
        <cp caption="Rate Limiting">
          <p>API calls are limited to 1000 requests per hour.</p>
        </cp>
      </poml>
    POML
    
    stylesheet = {
      'role' => {
        'captionStyle' => 'bold',
        'caption' => 'System Role'
      },
      'cp' => {
        'captionStyle' => 'header'
      }
    }
    
    result = Poml.process(markup: markup, stylesheet: stylesheet)
    assert result['content'].include?('API Documentation Writer')
    assert result['content'].include?('Authentication')
    assert result['content'].include?('Rate Limiting')
  end

  def test_file_operations_examples
    # Test saving output to files
    markup = <<~POML
      <poml>
        <role>Report Generator</role>
        <task>Generate monthly performance report</task>
      </poml>
    POML
    
    Tempfile.create(['test_output', '.txt']) do |temp_file|
      Poml.process(
        markup: markup, 
        format: 'raw',
        output_file: temp_file.path
      )
      
      content = File.read(temp_file.path)
      assert content.include?('Report Generator')
      assert content.include?('monthly performance report')
    end
  end

  def test_advanced_components_examples
    # Examples and Input/Output patterns
    markup = <<~POML
      <poml>
        <role>Code Generator</role>
        <task>Generate Ruby code based on examples</task>
        
        <example>
          <input>Create a User class with name and email</input>
          <output>
  class User
    attr_accessor :name, :email
    
    def initialize(name, email)
      @name = name
      @email = email
    end
  end
          </output>
        </example>
      </poml>
    POML
    
    result = Poml.process(markup: markup)
    assert result['content'].include?('Code Generator')
    assert result['content'].include?('Create a User class')
    assert result['content'].include?('class User')
  end

  def test_xml_syntax_mode_example
    markup = <<~POML
      <poml syntax="xml">
        <role>System Architect</role>
        <cp caption="Requirements Analysis">
          <list>
            <item>Scalability requirements</item>
            <item>Performance benchmarks</item>
            <item>Security considerations</item>
          </list>
        </cp>
        
        <cp caption="Technical Recommendations">
          <p>Based on the analysis, recommend appropriate architecture.</p>
        </cp>
      </poml>
    POML
    
    result = Poml.process(markup: markup, format: 'raw')
    assert result.include?('System Architect')
    assert result.include?('Requirements Analysis')
    assert result.include?('Scalability requirements')
    assert result.include?('Technical Recommendations')
  end

  def test_error_handling_examples
    # Basic error handling
    error_caught = false
    begin
      Poml.process(markup: '<poml><role>Test</role></poml>', format: 'invalid_format')
    rescue Poml::Error => e
      error_caught = true
      assert_kind_of String, e.message
    end
    assert error_caught, "Expected Poml::Error to be raised for invalid format"
    
    # Safe processing pattern
    def safe_process_poml(markup, options = {})
      return { error: "Empty markup" } if markup.nil? || markup.strip.empty?
      return { error: "Markup must contain <poml> tags" } unless markup.include?('<poml>')
      
      begin
        result = Poml.process(markup: markup, **options)
        { success: true, result: result }
      rescue Poml::Error => e
        { error: "POML processing error: #{e.message}" }
      rescue StandardError => e
        { error: "Unexpected error: #{e.message}" }
      end
    end
    
    # Test successful processing
    markup = '<poml><role>Assistant</role><task>Help users</task></poml>'
    response = safe_process_poml(markup, format: 'raw')
    assert response[:success]
    assert response[:result].include?('Assistant')
    
    # Test error handling
    response = safe_process_poml('', format: 'raw')
    assert response[:error]
    assert_equal "Empty markup", response[:error]
  end

  def test_integration_patterns
    # Service class pattern from Rails integration example
    prompt_service = Class.new do
      def self.create_support_prompt(user_name, user_email, issue_type, description)
        markup = <<~POML
          <poml>
            <role>Customer Support Specialist</role>
            <task>Help resolve {{issue_type}} for user {{user_name}}</task>
            
            <p>User Information:</p>
            <list>
              <item>Name: {{user_name}}</item>
              <item>Email: {{user_email}}</item>
            </list>
            
            <p>Issue Description:</p>
            <p>{{description}}</p>
            
            <hint>Be empathetic and provide step-by-step solutions</hint>
          </poml>
        POML
        
        context = {
          'user_name' => user_name,
          'user_email' => user_email,
          'issue_type' => issue_type,
          'description' => description
        }
        
        Poml.process(markup: markup, context: context, format: 'raw')
      end
    end
    
    prompt = prompt_service.create_support_prompt(
      'John Doe',
      'john@example.com',
      'login issue',
      'Cannot access my account'
    )
    
    assert prompt.include?('Customer Support Specialist')
    assert prompt.include?('John Doe')
    assert prompt.include?('john@example.com')
    assert prompt.include?('login issue')
    assert prompt.include?('Cannot access my account')
  end

  def test_best_practices_examples
    # Template organization pattern - simplified version
    basic_review_template = <<~POML
      <poml>
        <role>Senior {{language}} Developer</role>
        <task>Review the following code for best practices</task>
        <hint>Focus on readability, performance, and maintainability</hint>
      </poml>
    POML
    
    def generate_code_review_prompt(template, language)
      context = { 'language' => language }
      Poml.process(markup: template, context: context)
    end
    
    result = generate_code_review_prompt(basic_review_template, 'Ruby')
    assert result['content'].include?('Senior Ruby Developer')
    assert result['content'].include?('readability, performance')
    
    # Context validation pattern
    validation_class = Class.new do
      def self.required_fields
        {
          'code_review' => %w[language],
          'user_support' => %w[user_name issue_type]
        }
      end
      
      def self.validate_context!(template_type, context)
        required = required_fields[template_type]
        return unless required
        
        missing = required - context.keys
        raise ArgumentError, "Missing required fields: #{missing.join(', ')}" if missing.any?
      end
    end
    
    # Test successful validation
    validation_class.validate_context!('code_review', { 'language' => 'Ruby' })
    
    # Test failed validation
    assert_raises(ArgumentError) do
      validation_class.validate_context!('user_support', { 'user_name' => 'John' })
    end
  end

  def test_openai_integration_example
    markup = '<poml><role>AI Assistant</role><task>Help with coding</task></poml>'
    messages = Poml.process(markup: markup, format: 'openai_chat')
    
    # Simulate OpenAI API payload structure
    api_payload = {
      model: 'gpt-4',
      messages: messages,
      max_tokens: 1000
    }
    
    assert_kind_of Hash, api_payload
    assert_equal 'gpt-4', api_payload[:model]
    assert_equal messages, api_payload[:messages]
    assert_equal 1000, api_payload[:max_tokens]
    
    # Verify message structure is OpenAI compatible
    messages.each do |message|
      assert message.key?('role')
      assert message.key?('content')
      assert_includes ['system', 'user', 'assistant'], message['role']
    end
  end

  def test_performance_considerations
    # Test that repeated processing doesn't degrade performance significantly
    markup = '<poml><role>Performance Test</role><task>{{task_name}}</task></poml>'
    
    # Measure multiple processings
    times = []
    10.times do |i|
      start_time = Time.now
      context = { 'task_name' => "Task #{i}" }
      result = Poml.process(markup: markup, context: context, format: 'dict')
      end_time = Time.now
      
      times << (end_time - start_time)
      assert result['content'].include?("Task #{i}")
    end
    
    # Verify consistent performance (no major degradation)
    avg_time = times.sum / times.length
    max_time = times.max
    
    # Each operation should complete in reasonable time
    assert avg_time < 0.1, "Average processing time #{avg_time} too slow"
    assert max_time < 0.2, "Maximum processing time #{max_time} too slow"
  end

  def test_all_tutorial_format_examples_comprehensive
    # Comprehensive test that every format example from tutorial works
    base_markup = '<poml><role>Tutorial Test</role><task>Verify all formats work</task></poml>'
    
    # Test each format with assertions specific to tutorial examples
    result = Poml.process(markup: base_markup, format: 'raw')
    assert_kind_of String, result
    assert(result.include?('Tutorial Test') || result.include?('system'))
    
    result = Poml.process(markup: base_markup, format: 'dict')
    assert_kind_of Hash, result
    assert result.key?('content')
    assert result.key?('metadata')
    
    result = Poml.process(markup: base_markup, format: 'openai_chat')
    assert_kind_of Array, result
    assert result.length > 0
    assert result.first.key?('role')
    
    result = Poml.process(markup: base_markup, format: 'langchain')
    assert_kind_of Hash, result
    assert result.key?('messages')
    assert result.key?('content')
    
    result = Poml.process(markup: base_markup, format: 'pydantic')
    assert_kind_of Hash, result
    assert result.key?('content')  # Pydantic format uses 'content' key, not 'prompt'
    assert result.key?('variables')
    assert result.key?('chat_enabled')
  end
end
