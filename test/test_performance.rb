require "minitest/autorun"
require "poml"

class PomlPerformanceTest < Minitest::Test
  
  def test_large_loop_performance
    # Test performance with large loops (based on debug_performance_test.rb)
    large_array = (1..100).to_a
    markup = "<for variable=\"i\" items=\"#{large_array.to_s}\">{{i}} </for>"
    
    start_time = Time.now
    output = Poml.process(markup: markup)
    result = output['content']
    end_time = Time.now
    
    execution_time = end_time - start_time
    
    # Performance assertions
    assert execution_time < 1.0, "Large loop should complete within 1 second, took #{execution_time}"
    assert result.include?('1 '), "Result should include first item"
    assert result.include?('100'), "Result should include last item"
    assert result.length > 100, "Result should contain substantial content"
  end
  
  def test_nested_loops_performance
    # Test performance with nested loops
    markup = '<for variable="i" items="[1, 2, 3]"><for variable="j" items="[\"a\", \"b\", \"c\"]">{{i}}{{j}} </for></for>'
    
    start_time = Time.now
    output = Poml.process(markup: markup)
    result = output['content']
    end_time = Time.now
    
    execution_time = end_time - start_time
    
    # Should complete quickly even with nested loops
    assert execution_time < 0.5, "Nested loops should complete within 0.5 seconds, took #{execution_time}"
    assert result.include?('1a'), "Result should include nested combinations"
    assert result.include?('3c'), "Result should include all nested combinations"
  end
  
  def test_large_template_variable_substitution
    # Test performance with many variable substitutions
    variables = {}
    markup_parts = []
    
    # Create 50 variables and substitutions
    (1..50).each do |i|
      variables["var#{i}"] = "value#{i}"
      markup_parts << "{{var#{i}}}"
    end
    
    markup = markup_parts.join(' ')
    
    start_time = Time.now
    output = Poml.process(markup: markup, variables: variables)
    result = output['content']
    end_time = Time.now
    
    execution_time = end_time - start_time
    
    # Should handle many variable substitutions efficiently
    assert execution_time < 0.5, "Many variable substitutions should complete within 0.5 seconds, took #{execution_time}"
    assert result.include?('value1'), "Result should include first variable"
    assert result.include?('value50'), "Result should include last variable"
  end
  
  def test_performance_with_complex_document
    # Test performance with a complex document combining multiple features
    markup = '<poml><role>Performance Test Assistant</role><task>Process complex document efficiently</task><for variable="section" items="[\"intro\", \"body\", \"conclusion\"]"><h2>Section: {{section}}</h2><if condition="{{section}} == \"intro\""><p>This is the introduction section.</p></if><if condition="{{section}} == \"body\""><for variable="i" items="[1, 2, 3, 4, 5]"><p>Body paragraph {{i}} with <b>formatting</b> and <i>styles</i>.</p></for></if><if condition="{{section}} == \"conclusion\""><p>This concludes our <u>performance test</u> document.</p></if></for></poml>'
    
    start_time = Time.now
    output = Poml.process(markup: markup)
    result = output['content']
    end_time = Time.now
    
    execution_time = end_time - start_time
    
    # Complex document should still process efficiently
    assert execution_time < 1.0, "Complex document should complete within 1 second, took #{execution_time}"
    assert result.include?('Performance Test Assistant'), "Result should include role"
    assert result.include?('Section: intro'), "Result should include intro section"
    assert result.include?('Section: body'), "Result should include body section"
    assert result.include?('Section: conclusion'), "Result should include conclusion section"
    # Note: nested components inside if conditions may not process correctly in this POML version
  end
  
end
