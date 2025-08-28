require_relative 'test_helper'

class TestEdgeCasesAndErrorHandling < Minitest::Test
  include TestHelper

  def test_safe_variable_substitution
    # Test case from debug_safe_all_cases.rb - ensure safe substitution
    context_vars = {
      'expert_type' => 'Ruby',
      'tasks' => [{ 'priority' => 'High', 'title' => 'Fix critical bug' }]
    }

    markup = <<~POML
      <poml>
        <role>{{expert_type}} Expert</role>
        <task>Safe substitution test</task>
        
        <p>Expert: {{expert_type}}</p>
        <p>Tasks available: {{tasks.length}}</p>
        <p>Undefined variable: {{nonexistent}}</p>
        <p>Nested undefined: {{user.name}}</p>
        
        <for variable="task" items="{{tasks}}">
          <p>Task: {{task.priority}} - {{task.title}}</p>
          <p>Undefined in loop: {{task.undefined_field}}</p>
        </for>
      </poml>
    POML

    result = Poml.process(markup: markup, context: context_vars)
    content = result['content']

    # Defined variables should be substituted
    assert_includes content, 'Ruby Expert'
    assert_includes content, 'Expert: Ruby'
    assert_includes content, 'Tasks available: 1'
    assert_includes content, 'Task: High - Fix critical bug'
    
    # Undefined variables should remain as-is (not cause errors)
    assert_includes content, 'Undefined variable: {{nonexistent}}'
    assert_includes content, 'Nested undefined: {{user.name}}'
    assert_includes content, 'Undefined in loop: {{task.undefined_field}}'
  end

  def test_multiline_content_handling
    # Test case for multiline content preservation
    markup = <<~POML
      <poml>
        <role>Content Formatter</role>
        <task>Handle multiline content</task>
        
        <code-block language="yaml">
        database:
          host: localhost
          port: 5432
          name: myapp_production
          credentials:
            username: app_user
            password: secure_password
        
        redis:
          host: redis.example.com
          port: 6379
        </code-block>
        
        <p>The configuration above shows multiple lines with proper indentation.</p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']

    # Test that multiline content is preserved
    assert_includes content, '```yaml'
    assert_includes content, 'database:'
    assert_includes content, 'host: localhost'
    assert_includes content, 'port: 5432'
    assert_includes content, 'credentials:'
    assert_includes content, 'redis:'
    
    # Test content after code block is properly formatted (markdown)
    assert_includes content, 'The configuration above shows multiple lines'
  end

  def test_nested_component_handling
    # Test deeply nested components
    markup = <<~POML
      <poml>
        <role>Component Tester</role>
        <task>Test nested components</task>
        
        <callout type="warning">
          <h3>Important Notice</h3>
          <p>This is a <b>critical</b> warning with nested content:</p>
          
          <list>
            <item>First item with <i>italic</i> text</item>
            <item>Second item with <code>code snippet</code></item>
            <item>
              Third item with nested callout:
              <callout type="info">
                <p><b>Info:</b> Nested callouts should work properly.</p>
              </callout>
            </item>
          </list>
          
          <p>End of warning with <u>underlined</u> text.</p>
        </callout>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']

    # Test outer callout (markdown format with emoji)
    assert_includes content, '⚠️'
    assert_includes content, '### Important Notice'
    assert_includes content, '**critical**'
    
    # Test nested list within callout (markdown format)
    assert_includes content, '*italic*'
    assert_includes content, '`code snippet`'
    
    # Test nested callout within item (markdown format with emoji)
    assert_includes content, 'ℹ️'
    assert_includes content, '**Info:**'
    
    # Test formatting at the end (markdown format)
    assert_includes content, '__underlined__'
  end

  def test_empty_and_null_context_handling
    # Test handling of empty contexts and null values
    markup = <<~POML
      <poml>
        <role>{{role_name}}</role>
        <task>Handle empty context</task>
        
        <p>User: {{user.name}}</p>
        <p>Items count: {{items.length}}</p>
        
        <if condition="{{items.length}} > 0">
          <p>Items exist!</p>
        </if>
        
        <for variable="item" items="{{items}}">
          <p>Item: {{item.name}}</p>
        </for>
      </poml>
    POML

    # Test with empty context
    empty_result = Poml.process(markup: markup, context: {})
    empty_content = empty_result['content']

    # Undefined variables should remain as template expressions
    assert_includes empty_content, '{{role_name}}'
    assert_includes empty_content, '{{user.name}}'
    assert_includes empty_content, '{{items.length}}'
    
    # Test with null/empty arrays
    null_context = {
      'role_name' => nil,
      'user' => nil,
      'items' => []
    }
    
    null_result = Poml.process(markup: markup, context: null_context)
    null_content = null_result['content']

    # Null values should be handled gracefully
    refute_includes null_content, 'Items exist!'
  end

  def test_special_characters_and_encoding
    # Test handling of special characters and encoding
    markup = <<~POML
      <poml>
        <role>Unicode Tester</role>
        <task>Test special characters</task>
        
        <h1>Special Characters Test</h1>
        
        <p>Emojis: 🚀 🎉 ⚠️ ✅ ❌ 🔥</p>
        <p>Accents: café, naïve, Zürich, Москва</p>
        <p>Symbols: © ® ™ € $ £ ¥</p>
        <p>Math: ∑ ∞ π α β γ Δ</p>
        
        <code-block language="text">
Special chars in code: 
  - Arrows: → ← ↑ ↓
  - Quotes: "smart" 'quotes' 
  - Dashes: en–dash em—dash
        </code-block>
        
        <table>
          <thead>
            <tr>
              <th>Character</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>→</td>
              <td>Right arrow</td>
            </tr>
            <tr>
              <td>©</td>
              <td>Copyright symbol</td>
            </tr>
          </tbody>
        </table>
      </poml>
    POML

    result = Poml.process(markup: markup)
    content = result['content']

    # Test emojis are preserved
    assert_includes content, '🚀'
    assert_includes content, '⚠️'
    assert_includes content, '✅'
    
    # Test accented characters
    assert_includes content, 'café'
    assert_includes content, 'naïve'
    assert_includes content, 'Zürich'
    
    # Test symbols
    assert_includes content, '©'
    assert_includes content, '€'
    assert_includes content, '™'
    
    # Test math symbols
    assert_includes content, 'π'
    assert_includes content, 'Δ'
    
    # Test table with special characters (markdown format)
    assert_includes content, '| Character | Description |'
    assert_includes content, '| → | Right arrow |'
    assert_includes content, '| © | Copyright symbol |'
  end

  def test_large_content_processing
    # Test processing of larger content volumes
    large_items = (1..50).map do |i|
      {
        'id' => i,
        'name' => "Item #{i}",
        'description' => "This is a detailed description for item number #{i}. " * 3,
        'active' => i % 3 == 0
      }
    end

    markup = <<~POML
      <poml>
        <role>Data Processor</role>
        <task>Process large dataset</task>
        
        <h1>Large Dataset Processing</h1>
        <p>Processing {{items.length}} items...</p>
        
        <h2>Active Items</h2>
        <for variable="item" items="{{items}}">
          <if condition="{{item.active}}">
            <h3>{{item.name}}</h3>
            <p><b>ID:</b> {{item.id}}</p>
            <p><b>Description:</b> {{item.description}}</p>
          </if>
        </for>
        
        <h2>Summary</h2>
        <p>Processed {{items.length}} total items.</p>
      </poml>
    POML

    context = { 'items' => large_items }

    result = Poml.process(markup: markup, context: context)
    content = result['content']

    # Test that large content is processed correctly
    assert_includes content, 'Processing 50 items'
    assert_includes content, 'Processed 50 total items'
    
    # Test that only active items appear (multiples of 3)
    assert_includes content, '### Item 3'
    assert_includes content, '### Item 6'
    assert_includes content, '### Item 9'
    assert_includes content, '### Item 12'
    assert_includes content, '### Item 48'
    
    # Test that descriptions are included
    assert_includes content, 'detailed description for item number 3'
  end

  def test_malformed_template_expressions
    # Test handling of malformed template expressions
    markup = <<~POML
      <poml>
        <role>Error Handler</role>
        <task>Handle malformed expressions</task>
        
        <p>Valid: {{valid_var}}</p>
        <p>Incomplete: {{incomplete</p>
        <p>Extra braces: {{{extra_braces}}}</p>
        <p>Empty: {{}}</p>
        <p>Spaces: {{ spaced_var }}</p>
        <p>Invalid syntax: {{invalid.}}</p>
        <p>Nested: {{outer.{{inner}}}}</p>
      </poml>
    POML

    context = {
      'valid_var' => 'This works',
      'spaced_var' => 'Spaced works too'
    }

    result = Poml.process(markup: markup, context: context)
    content = result['content']

    # Valid expressions should work
    assert_includes content, 'Valid: This works'
    assert_includes content, 'Spaces: Spaced works too'
    
    # Malformed expressions should be left as-is (not crash)
    assert_includes content, 'Incomplete: {{incomplete'
    assert_includes content, 'Extra braces: {{{extra_braces}}}'
    assert_includes content, 'Empty: {{}}'
    assert_includes content, 'Invalid syntax: {{invalid.}}'
    assert_includes content, 'Nested: {{outer.{{inner}}}}'
  end
end
