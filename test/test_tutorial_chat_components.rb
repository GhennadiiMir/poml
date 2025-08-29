require "minitest/autorun"
require "poml"

class TutorialChatComponentsTest < Minitest::Test
  # Tests for docs/tutorial/components/chat-components.md examples
  
  def test_system_component_basic
    # From "System Component" section
    markup = <<~POML
      <poml>
        <system>
          You are a helpful assistant specializing in Ruby programming. 
          Provide clear, practical solutions with code examples.
          Always explain your reasoning and suggest best practices.
        </system>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_kind_of Array, result
    assert_equal 1, result.length
    assert_equal 'system', result[0]['role']
    assert result[0]['content'].include?('helpful assistant specializing in Ruby')
    assert result[0]['content'].include?('code examples')
    assert result[0]['content'].include?('best practices')
  end

  def test_human_component_basic
    # From "Human Component" section
    markup = <<~POML
      <poml>
        <system>You are a code review assistant.</system>
        
        <human>
          Please review this Ruby method for potential improvements:
          
          <code>
          def calculate_total(items)
            total = 0
            items.each do |item|
              total += item.price
            end
            total
          end
          </code>
          
          <p>Focus on performance and Ruby idioms.</p>
        </human>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_kind_of Array, result
    assert_equal 2, result.length
    
    # System message
    assert_equal 'system', result[0]['role']
    assert result[0]['content'].include?('code review assistant')
    
    # Human message
    assert_equal 'user', result[1]['role']
    assert result[1]['content'].include?('review this Ruby method')
    assert result[1]['content'].include?('calculate_total')
    assert result[1]['content'].include?('Focus on performance')
  end

  def test_ai_component_basic
    # From "AI Component" section
    markup = <<~POML
      <poml>
        <system>You are a Ruby expert.</system>
        
        <human>How can I optimize this code?</human>
        
        <ai>
          I can see several opportunities for optimization in your code:
          
          <list>
            <item><b>Use reduce:</b> Replace the manual loop with <code>reduce</code></item>
            <item><b>Use sum:</b> Even better, use <code>sum</code> method</item>
          </list>
          
          <p>Here's the improved version:</p>
          <code>
          def calculate_total(items)
            items.sum(&:price)
          end
          </code>
        </ai>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_kind_of Array, result
    assert_equal 3, result.length
    
    # System message
    assert_equal 'system', result[0]['role']
    
    # Human message  
    assert_equal 'user', result[1]['role']
    
    # AI message
    assert_equal 'assistant', result[2]['role']
    assert result[2]['content'].include?('opportunities for optimization')
    assert result[2]['content'].include?('Use reduce')
    assert result[2]['content'].include?('items.sum(&amp;:price)')
  end

  def test_multi_turn_conversation
    # From "Multi-turn Conversations" section
    markup = <<~POML
      <poml>
        <system>You are a helpful programming tutor.</system>
        
        <human>What's the difference between a class and an object in Ruby?</human>
        
        <ai>
          Great question! Here's the difference:
          
          <list>
            <item><b>Class:</b> A blueprint or template for creating objects</item>
            <item><b>Object:</b> An instance of a class</item>
          </list>
        </ai>
        
        <human>Can you show me an example?</human>
        
        <ai>
          Absolutely! Here's a simple example:
          
          <code>
          # This is a class (blueprint)
          class Car
            def initialize(brand, model)
              @brand = brand
              @model = model
            end
          end
          
          # These are objects (instances)
          car1 = Car.new("Toyota", "Camry")
          car2 = Car.new("Honda", "Civic")
          </code>
        </ai>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_kind_of Array, result
    assert_equal 5, result.length
    
    # Verify message roles
    assert_equal 'system', result[0]['role']
    assert_equal 'user', result[1]['role']
    assert_equal 'assistant', result[2]['role']
    assert_equal 'user', result[3]['role']
    assert_equal 'assistant', result[4]['role']
    
    # Verify content flow
    assert result[1]['content'].include?("What's the difference between")
    assert result[2]['content'].include?('blueprint or template')
    assert result[3]['content'].include?('show me an example')
    assert result[4]['content'].include?('class Car')
  end

  def test_chat_with_template_variables
    # From "Chat with Template Variables" section
    markup = <<~POML
      <poml>
        <system>You are a {{role_type}} with {{experience}} years of experience.</system>
        
        <human>
          I'm working on {{project_type}} and need advice on {{specific_topic}}.
          
          <p>Current challenges:</p>
          <list>
            <item>{{challenge_1}}</item>
            <item>{{challenge_2}}</item>
          </list>
        </human>
      </poml>
    POML

    context = {
      'role_type' => 'Senior Developer',
      'experience' => '10',
      'project_type' => 'web application',
      'specific_topic' => 'database optimization',
      'challenge_1' => 'slow queries',
      'challenge_2' => 'high memory usage'
    }

    result = Poml.process(markup: markup, context: context, format: 'openai_chat')
    
    assert_kind_of Array, result
    assert_equal 2, result.length
    
    # System message with variables
    system_content = result[0]['content']
    assert system_content.include?('Senior Developer')
    assert system_content.include?('10 years of experience')
    
    # Human message with variables
    human_content = result[1]['content']
    assert human_content.include?('web application')
    assert human_content.include?('database optimization')
    assert human_content.include?('slow queries')
    assert human_content.include?('high memory usage')
    
    # Verify no unreplaced variables
    refute system_content.include?('{{role_type}}')
    refute human_content.include?('{{project_type}}')
  end

  def test_chat_format_compatibility
    # From "Format Compatibility" section
    markup = <<~POML
      <poml>
        <system>You are an assistant.</system>
        <human>Hello!</human>
      </poml>
    POML

    # OpenAI Chat format
    openai_result = Poml.process(markup: markup, format: 'openai_chat')
    assert_kind_of Array, openai_result
    assert_equal 2, openai_result.length
    assert_equal 'system', openai_result[0]['role']
    assert_equal 'user', openai_result[1]['role']

    # OpenAI Response format
    response_result = Poml.process(markup: markup, format: 'openaiResponse')
    assert_kind_of Hash, response_result
    assert response_result.key?('messages')
    assert_kind_of Array, response_result['messages']

    # LangChain format
    langchain_result = Poml.process(markup: markup, format: 'langchain')
    assert_kind_of Hash, langchain_result
    assert langchain_result.key?('messages')
    assert langchain_result.key?('content')

    # Raw format should preserve structure differently
    raw_result = Poml.process(markup: markup, format: 'raw')
    assert_kind_of String, raw_result
    # In raw format with chat mode (default), chat components return empty content
    # They delegate to structured messages instead
    assert raw_result.strip.empty?
  end

  def test_custom_speaker_names
    # From "Custom Speaker Names" section
    markup = <<~POML
      <poml>
        <system>You are facilitating a team discussion.</system>
        
        <human speaker="Alice">
          I think we should use React for the frontend.
        </human>
        
        <human speaker="Bob">
          What about Vue.js? It might be simpler for our team.
        </human>
        
        <ai speaker="Facilitator">
          Both are excellent choices. Let's compare them:
          
          <list>
            <item><b>React:</b> Large ecosystem, more job opportunities</item>
            <item><b>Vue.js:</b> Gentler learning curve, good documentation</item>
          </list>
        </ai>
      </poml>
    POML

    result = Poml.process(markup: markup, format: 'openai_chat')
    
    assert_kind_of Array, result
    assert_equal 4, result.length
    
    # Verify roles are properly set
    assert_equal 'system', result[0]['role']
    assert_equal 'user', result[1]['role']
    assert_equal 'user', result[2]['role']
    assert_equal 'assistant', result[3]['role']
    
    # Verify content includes speaker context
    assert result[1]['content'].include?('React for the frontend')
    assert result[2]['content'].include?('Vue.js')
    assert result[3]['content'].include?('Both are excellent choices')
  end

  def test_conditional_chat_content
    # From "Conditional Content" section
    markup = <<~POML
      <poml>
        <system>You are a helpful assistant.</system>
        
        <human>
          I need help with {{request_type}}.
          
          <if condition="{{include_urgency}}">
            <p><b>Priority:</b> {{urgency_level}}</p>
          </if>
          
          <if condition="{{include_context}}">
            <p><b>Context:</b> {{background_info}}</p>
          </if>
        </human>
      </poml>
    POML

    # Test with urgency but no context
    context1 = {
      'request_type' => 'database optimization',
      'include_urgency' => true,
      'urgency_level' => 'High',
      'include_context' => false
    }

    result1 = Poml.process(markup: markup, context: context1, format: 'openai_chat')
    human_content1 = result1[1]['content']
    
    assert human_content1.include?('database optimization')
    assert human_content1.include?('Priority:')
    assert human_content1.include?('High')
    refute human_content1.include?('Context:')

    # Test with context but no urgency
    context2 = {
      'request_type' => 'code review',
      'include_urgency' => false,
      'include_context' => true,
      'background_info' => 'Legacy codebase migration'
    }

    result2 = Poml.process(markup: markup, context: context2, format: 'openai_chat')
    human_content2 = result2[1]['content']
    
    assert human_content2.include?('code review')
    refute human_content2.include?('Priority:')
    assert human_content2.include?('Context:')
    assert human_content2.include?('Legacy codebase migration')
  end

  def test_performance_with_large_conversations
    # Test performance with multiple messages
    markup = <<~POML
      <poml>
        <system>You are a helpful assistant.</system>
        
        <human>Question 1</human>
        <ai>Answer 1</ai>
        <human>Question 2</human>  
        <ai>Answer 2</ai>
        <human>Question 3</human>
        <ai>Answer 3</ai>
        <human>Question 4</human>
        <ai>Answer 4</ai>
        <human>Question 5</human>
        <ai>Answer 5</ai>
      </poml>
    POML

    start_time = Time.now
    result = Poml.process(markup: markup, format: 'openai_chat')
    end_time = Time.now
    
    assert_kind_of Array, result
    assert_equal 11, result.length  # 1 system + 10 messages
    
    # Should process quickly
    processing_time = end_time - start_time
    assert processing_time < 0.1, "Processing took too long: #{processing_time}s"
    
    # Verify alternating pattern
    assert_equal 'system', result[0]['role']
    (1...result.length).each do |i|
      expected_role = i.odd? ? 'user' : 'assistant'
      assert_equal expected_role, result[i]['role']
    end
  end
end
