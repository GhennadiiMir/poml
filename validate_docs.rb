#!/usr/bin/env ruby

# Documentation validation script
# Tests that examples in our documentation actually work

require_relative 'lib/poml'

puts "Testing documentation examples..."

examples = [
  {
    name: "Basic usage",
    markup: <<~POML
      <poml>
        <role>Expert Assistant</role>
        <task>Help users with their questions</task>
        <p>How can I help you today?</p>
      </poml>
    POML
  },
  {
    name: "Template variables",
    markup: <<~POML,
      <poml>
        <role>{{role_name}}</role>
        <task>Answer questions about {{topic}}</task>
      </poml>
    POML
    variables: {
      'role_name' => 'Science Teacher',
      'topic' => 'physics'
    }
  },
  {
    name: "Tool registration",
    markup: <<~POML,
      <poml>
        <tool-definition name="calculate" description="Perform calculations" parser="json">
          {
            "type": "object",
            "properties": {
              "operation": { "type": "string", "enum": ["add", "subtract"] },
              "a": { "type": "number" },
              "b": { "type": "number" }
            },
            "required": ["operation", "a", "b"]
          }
        </tool-definition>
        
        <role>Math Assistant</role>
        <task>Help with calculations using the calculate tool</task>
      </poml>
    POML
    expects_tools: true
  },
  {
    name: "Response schema",
    markup: <<~POML,
      <poml>
        <output-schema parser="json">
          {
            "type": "object",
            "properties": {
              "answer": { "type": "string" },
              "confidence": { "type": "number" }
            },
            "required": ["answer"]
          }
        </output-schema>
        
        <role>Expert Assistant</role>
        <task>Provide structured responses</task>
      </poml>
    POML
    expects_schema: true
  }
]

failures = 0

examples.each do |example|
  begin
    puts "Testing: #{example[:name]}"
    
    result = Poml.process(
      markup: example[:markup],
      variables: example[:variables]
    )
    
    # Basic validation
    unless result.is_a?(Hash) && result['content']
      raise "Invalid result format"
    end
    
    # Check for tools if expected
    if example[:expects_tools]
      unless result['tools'] && result['tools'].is_a?(Array) && result['tools'].length > 0
        raise "Tools not found in result"
      end
      puts "    Tools found: #{result['tools'].length}"
    end
    
    # Check for schema if expected  
    if example[:expects_schema]
      unless result['metadata'] && result['metadata']['response_schema']
        raise "Response schema not found in metadata"
      end
      puts "    Schema found: #{result['metadata']['response_schema'] ? 'yes' : 'no'}"
    end
    
    puts "  ✓ Passed"
    
  rescue => e
    puts "  ✗ Failed: #{e.message}"
    failures += 1
  end
end

puts "\nValidation complete!"
puts "#{examples.length - failures}/#{examples.length} examples passed"

if failures > 0
  puts "⚠️  #{failures} examples failed - documentation may need updates"
  exit 1
else
  puts "🎉 All documentation examples are working correctly!"
end
