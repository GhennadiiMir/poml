require "minitest/autorun"
require "poml"

class TutorialToolRegistrationTest < Minitest::Test
  # Tests for docs/tutorial/tool-registration.md examples
  
  def test_basic_tool_registration
    # From "Basic Tool Registration" section
    markup = <<~POML
      <poml>
        <tools>
          <tool name="get_weather">
            <description>Get current weather information for a location</description>
            <parameter name="location" type="string" required="true">
              <description>The city or location to get weather for</description>
            </parameter>
            <parameter name="units" type="string" required="false">
              <description>Temperature units: celsius or fahrenheit (default: celsius)</description>
            </parameter>
          </tool>
        </tools>
        
        <role>Weather Assistant</role>
        <task>Help users get weather information</task>
        
        <p>I can help you get current weather information for any location. 
        Just tell me the city name and I'll fetch the weather data for you.</p>
        
        <p>Available tool: <b>get_weather</b> - retrieves current weather conditions</p>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result.key?('content')
    assert result.key?('metadata')
    assert result.key?('tools')
    
    content = result['content']
    tools = result['tools']
    
    assert content.include?('Weather Assistant')
    assert content.include?('weather information')
    assert content.include?('get_weather')
    
    # Should have registered tools
    assert tools.is_a?(Array)
    assert tools.length == 1
    
    weather_tool = tools[0]
    assert weather_tool['name'] == 'get_weather'
    assert weather_tool['description'].include?('current weather information')
    
    # Check parameters
    assert weather_tool.key?('parameters')
    params = weather_tool['parameters']
    
    location_param = params['location']
    assert location_param['type'] == 'string'
    assert location_param['required'] == true
    assert location_param['description'].include?('city or location')
    
    units_param = params['units']
    assert units_param['type'] == 'string'
    assert units_param['required'] == false
    assert units_param['description'].include?('celsius or fahrenheit')
  end

  def test_multiple_tools_registration
    # From "Multiple Tools" section
    markup = <<~POML
      <poml>
        <tools>
          <tool name="search_web">
            <description>Search the web for information</description>
            <parameter name="query" type="string" required="true">
              <description>The search query</description>
            </parameter>
            <parameter name="max_results" type="integer" required="false">
              <description>Maximum number of results to return (default: 5)</description>
            </parameter>
          </tool>
          
          <tool name="get_stock_price">
            <description>Get current stock price for a ticker symbol</description>
            <parameter name="symbol" type="string" required="true">
              <description>Stock ticker symbol (e.g., AAPL, GOOGL)</description>
            </parameter>
            <parameter name="exchange" type="string" required="false">
              <description>Stock exchange (default: NASDAQ)</description>
            </parameter>
          </tool>
          
          <tool name="calculate">
            <description>Perform mathematical calculations</description>
            <parameter name="expression" type="string" required="true">
              <description>Mathematical expression to evaluate</description>
            </parameter>
            <parameter name="precision" type="integer" required="false">
              <description>Number of decimal places (default: 2)</description>
            </parameter>
          </tool>
        </tools>
        
        <role>Research Assistant</role>
        <task>Help with research, calculations, and market data</task>
        
        <p>I have access to multiple tools to help you:</p>
        <list>
          <item><b>Web Search:</b> Find information online</item>
          <item><b>Stock Prices:</b> Get current market data</item>
          <item><b>Calculator:</b> Perform mathematical calculations</item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result.key?('content')
    assert result.key?('metadata')
    assert result.key?('tools')
    
    content = result['content']
    tools = result['tools']
    
    assert content.include?('Research Assistant')
    assert content.include?('Web Search')
    assert content.include?('Stock Prices')
    assert content.include?('Calculator')
    
    # Should have 3 tools registered
    assert tools.is_a?(Array)
    assert tools.length == 3
    
    tool_names = tools.map { |t| t['name'] }
    assert tool_names.include?('search_web')
    assert tool_names.include?('get_stock_price')
    assert tool_names.include?('calculate')
    
    # Check search_web tool
    search_tool = tools.find { |t| t['name'] == 'search_web' }
    assert search_tool['description'].include?('Search the web')
    assert search_tool['parameters']['query']['required'] == true
    assert search_tool['parameters']['max_results']['required'] == false
    
    # Check stock tool
    stock_tool = tools.find { |t| t['name'] == 'get_stock_price' }
    assert stock_tool['description'].include?('stock price')
    assert stock_tool['parameters']['symbol']['description'].include?('AAPL, GOOGL')
    
    # Check calculator tool
    calc_tool = tools.find { |t| t['name'] == 'calculate' }
    assert calc_tool['description'].include?('mathematical calculations')
    assert calc_tool['parameters']['expression']['type'] == 'string'
  end

  def test_complex_parameter_types
    # From "Complex Parameter Types" section
    markup = <<~POML
      <poml>
        <tools>
          <tool name="analyze_data">
            <description>Analyze dataset with various options</description>
            
            <parameter name="data_source" type="string" required="true">
              <description>Path to data file or database connection string</description>
            </parameter>
            
            <parameter name="analysis_type" type="string" required="true">
              <description>Type of analysis: descriptive, predictive, or diagnostic</description>
              <enum>
                <value>descriptive</value>
                <value>predictive</value>
                <value>diagnostic</value>
              </enum>
            </parameter>
            
            <parameter name="columns" type="array" required="false">
              <description>Specific columns to analyze (default: all)</description>
              <items type="string">
                <description>Column name</description>
              </items>
            </parameter>
            
            <parameter name="options" type="object" required="false">
              <description>Additional analysis options</description>
              <properties>
                <property name="remove_outliers" type="boolean">
                  <description>Whether to remove statistical outliers</description>
                </property>
                <property name="confidence_level" type="number">
                  <description>Statistical confidence level (0.0 to 1.0)</description>
                </property>
                <property name="groupby" type="string">
                  <description>Column to group analysis by</description>
                </property>
              </properties>
            </parameter>
          </tool>
        </tools>
        
        <role>Data Analysis Expert</role>
        <task>Perform comprehensive data analysis</task>
        
        <p>I can analyze various types of datasets with sophisticated options including:</p>
        <list>
          <item>Descriptive statistics and summaries</item>
          <item>Predictive modeling and forecasting</item>
          <item>Diagnostic analysis for issue identification</item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result.key?('metadata')
    assert result.key?('tools')
    tools = result['tools']
    
    assert tools.length == 1
    tool = tools[0]
    
    assert tool['name'] == 'analyze_data'
    params = tool['parameters']
    
    # Check string parameter
    data_source = params['data_source']
    assert data_source['type'] == 'string'
    assert data_source['required'] == true
    
    # Check enum parameter
    analysis_type = params['analysis_type']
    assert analysis_type['type'] == 'string'
    assert analysis_type.key?('enum')
    assert analysis_type['enum'].include?('descriptive')
    assert analysis_type['enum'].include?('predictive')
    assert analysis_type['enum'].include?('diagnostic')
    
    # Check array parameter
    columns = params['columns']
    assert columns['type'] == 'array'
    assert columns['required'] == false
    assert columns['items']['type'] == 'string'
    
    # Check object parameter
    options = params['options']
    assert options['type'] == 'object'
    assert options['required'] == false
    assert options.key?('properties')
    
    properties = options['properties']
    assert properties['remove_outliers']['type'] == 'boolean'
    assert properties['confidence_level']['type'] == 'number'
    assert properties['groupby']['type'] == 'string'
  end

  def test_tool_with_schema_reference
    # From "Tool with Schema Reference" section
    markup = <<~POML
      <poml>
        <tools>
          <tool name="create_user">
            <description>Create a new user account</description>
            
            <parameter name="user_data" type="object" required="true">
              <description>User information</description>
              <schema>
                {
                  "type": "object",
                  "properties": {
                    "username": {
                      "type": "string",
                      "minLength": 3,
                      "maxLength": 20,
                      "pattern": "^[a-zA-Z0-9_]+$"
                    },
                    "email": {
                      "type": "string",
                      "format": "email"
                    },
                    "profile": {
                      "type": "object",
                      "properties": {
                        "first_name": {"type": "string"},
                        "last_name": {"type": "string"},
                        "age": {"type": "integer", "minimum": 13}
                      },
                      "required": ["first_name", "last_name"]
                    }
                  },
                  "required": ["username", "email", "profile"]
                }
              </schema>
            </parameter>
            
            <parameter name="send_welcome_email" type="boolean" required="false">
              <description>Whether to send welcome email (default: true)</description>
            </parameter>
          </tool>
        </tools>
        
        <role>User Management System</role>
        <task>Handle user account creation and management</task>
        
        <p>I can create new user accounts with proper validation:</p>
        <list>
          <item>Username validation (3-20 chars, alphanumeric + underscore)</item>
          <item>Email format validation</item>
          <item>Required profile information</item>
          <item>Age verification (minimum 13 years)</item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result.key?('metadata')
    assert result.key?('tools')
    tools = result['tools']
    
    assert tools.length == 1
    tool = tools[0]
    
    assert tool['name'] == 'create_user'
    params = tool['parameters']
    
    # Check user_data parameter with schema
    user_data = params['user_data']
    assert user_data['type'] == 'object'
    assert user_data['required'] == true
    assert user_data.key?('schema')
    
    schema = user_data['schema']
    if schema.is_a?(String)
      require 'json'
      schema = JSON.parse(schema)
    end
    
    assert schema['type'] == 'object'
    assert schema.key?('properties')
    assert schema['properties'].key?('username')
    assert schema['properties'].key?('email')
    assert schema['properties'].key?('profile')
    
    # Check nested schema properties
    username_props = schema['properties']['username']
    assert username_props['type'] == 'string'
    assert username_props['minLength'] == 3
    assert username_props['maxLength'] == 20
    
    email_props = schema['properties']['email']
    assert email_props['format'] == 'email'
    
    profile_props = schema['properties']['profile']
    assert profile_props['type'] == 'object'
    assert profile_props['required'].include?('first_name')
    assert profile_props['required'].include?('last_name')
  end

  def test_conditional_tool_registration
    # From "Conditional Tool Registration" section
    markup = <<~POML
      <poml>
        <tools>
          <if condition="{{enable_admin_tools}}">
            <tool name="delete_user">
              <description>Delete a user account (admin only)</description>
              <parameter name="user_id" type="integer" required="true">
                <description>ID of user to delete</description>
              </parameter>
              <parameter name="force" type="boolean" required="false">
                <description>Force deletion even if user has data</description>
              </parameter>
            </tool>
            
            <tool name="export_data">
              <description>Export system data (admin only)</description>
              <parameter name="format" type="string" required="true">
                <description>Export format: csv, json, or xml</description>
              </parameter>
              <parameter name="table" type="string" required="false">
                <description>Specific table to export (default: all)</description>
              </parameter>
            </tool>
          </if>
          
          <tool name="get_profile">
            <description>Get user profile information</description>
            <parameter name="user_id" type="integer" required="true">
              <description>User ID to get profile for</description>
            </parameter>
          </tool>
          
          <if condition="{{enable_analytics}}">
            <tool name="generate_report">
              <description>Generate analytics report</description>
              <parameter name="report_type" type="string" required="true">
                <description>Type of report to generate</description>
              </parameter>
            </tool>
          </if>
        </tools>
        
        <role>{{user_role}} Assistant</role>
        <task>Provide appropriate tools based on user permissions</task>
        
        <if condition="{{enable_admin_tools}}">
          <p><b>Admin Mode:</b> You have access to administrative tools including user management and data export.</p>
        </if>
        
        <if condition="!{{enable_admin_tools}}">
          <p><b>User Mode:</b> You have access to standard user tools.</p>
        </if>
      </poml>
    POML

    # Test with admin permissions
    admin_context = {
      'enable_admin_tools' => true,
      'enable_analytics' => true,
      'user_role' => 'Administrator'
    }

    admin_result = Poml.process(markup: markup, context: admin_context)
    admin_tools = admin_result['tools']
    
    # Should have all tools (admin + regular + analytics)
    assert admin_tools.length == 4
    tool_names = admin_tools.map { |t| t['name'] }
    assert tool_names.include?('delete_user')
    assert tool_names.include?('export_data')
    assert tool_names.include?('get_profile')
    assert tool_names.include?('generate_report')
    
    admin_content = admin_result['content']
    assert admin_content.include?('Administrator Assistant')
    assert admin_content.include?('Admin Mode')
    assert admin_content.include?('administrative tools')

    # Test with regular user permissions
    user_context = {
      'enable_admin_tools' => false,
      'enable_analytics' => false,
      'user_role' => 'User'
    }

    user_result = Poml.process(markup: markup, context: user_context)
    user_tools = user_result['tools']
    
    # Should only have regular tools
    assert user_tools.length == 1
    assert user_tools[0]['name'] == 'get_profile'
    
    user_content = user_result['content']
    assert user_content.include?('User Assistant')
    assert user_content.include?('User Mode')
    assert user_content.include?('standard user tools')
  end

  def test_tool_metadata_and_examples
    # From "Tool Metadata and Examples" section
    markup = <<~POML
      <poml>
        <tools>
          <tool name="send_email">
            <description>Send an email message</description>
            <version>1.2.0</version>
            <category>communication</category>
            <requires_auth>true</requires_auth>
            
            <parameter name="to" type="string" required="true">
              <description>Recipient email address</description>
              <example>user@example.com</example>
            </parameter>
            
            <parameter name="subject" type="string" required="true">
              <description>Email subject line</description>
              <example>Meeting reminder</example>
            </parameter>
            
            <parameter name="body" type="string" required="true">
              <description>Email message content</description>
              <example>Don't forget about our meeting tomorrow at 2 PM.</example>
            </parameter>
            
            <parameter name="attachments" type="array" required="false">
              <description>File attachments</description>
              <items type="string">
                <description>File path or URL</description>
                <example>/path/to/document.pdf</example>
              </items>
            </parameter>
            
            <example>
              <title>Send meeting reminder</title>
              <description>Send a reminder email about an upcoming meeting</description>
              <parameters>
                {
                  "to": "team@company.com",
                  "subject": "Weekly Team Meeting - Tomorrow 2 PM",
                  "body": "Hi team,\n\nJust a friendly reminder about our weekly team meeting tomorrow at 2 PM in Conference Room A.\n\nAgenda:\n- Project updates\n- Q1 planning\n- Open discussion\n\nSee you there!\nBest regards",
                  "attachments": ["/documents/agenda.pdf"]
                }
              </parameters>
            </example>
          </tool>
        </tools>
        
        <role>Email Assistant</role>
        <task>Help manage email communications</task>
        
        <p>I can help you send emails with the following features:</p>
        <list>
          <item>Professional formatting</item>
          <item>File attachments support</item>
          <item>Template suggestions</item>
          <item>Recipient validation</item>
        </list>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    assert result.key?('metadata')
    assert result.key?('tools')
    tools = result['tools']
    
    assert tools.length == 1
    tool = tools[0]
    
    assert tool['name'] == 'send_email'
    assert tool['description'].include?('Send an email')
    assert tool['version'] == '1.2.0'
    assert tool['category'] == 'communication'
    assert tool['requires_auth'] == true
    
    # Check parameter examples
    params = tool['parameters']
    assert params['to']['example'] == 'user@example.com'
    assert params['subject']['example'] == 'Meeting reminder'
    assert params['body']['example'].include?('meeting tomorrow')
    assert params['attachments']['items']['example'] == '/path/to/document.pdf'
    
    # Check tool example
    assert tool.key?('example')
    example = tool['example']
    assert example['title'] == 'Send meeting reminder'
    assert example['description'].include?('upcoming meeting')
    
    parameters = example['parameters']
    if parameters.is_a?(String)
      require 'json'
      parameters = JSON.parse(parameters)
    end
    
    assert parameters['to'] == 'team@company.com'
    assert parameters['subject'].include?('Weekly Team Meeting')
    assert parameters['body'].include?('friendly reminder')
    assert parameters['attachments'].include?('/documents/agenda.pdf')
  end

  def test_tool_registration_error_handling
    # Test error handling for malformed tool definitions
    markup = <<~POML
      <poml>
        <tools>
          <tool name="valid_tool">
            <description>A properly defined tool</description>
            <parameter name="param1" type="string" required="true">
              <description>A valid parameter</description>
            </parameter>
          </tool>
          
          <!-- This tool has missing required elements -->
          <tool name="incomplete_tool">
            <!-- Missing description -->
            <parameter name="param1" type="unknown_type" required="true">
              <!-- Missing description -->
            </parameter>
          </tool>
        </tools>
        
        <role>Test Assistant</role>
        <task>Test tool registration error handling</task>
      </poml>
    POML

    result = Poml.process(markup: markup)
    
    # Should still process successfully despite malformed tools
    assert result.key?('content')
    assert result.key?('metadata')
    assert result.key?('tools')
    
    content = result['content']
    assert content.include?('Test Assistant')
    
    tools = result['tools']
    # Should have at least the valid tool
    assert tools.is_a?(Array)
    
    # Find the valid tool
    valid_tool = tools.find { |t| t['name'] == 'valid_tool' }
    assert valid_tool
    assert valid_tool['description'] == 'A properly defined tool'
  end
end
