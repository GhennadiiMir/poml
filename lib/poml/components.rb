# Main components file - requires all component modules
require_relative 'components/base'
require_relative 'components/text'
require_relative 'components/instructions'
require_relative 'components/content'
require_relative 'components/data'
require_relative 'components/examples'
require_relative 'components/lists'
require_relative 'components/layout'
require_relative 'components/workflow'
require_relative 'components/styling'

module Poml
  # Update the component mapping after all components are loaded
  Components::COMPONENT_MAPPING.merge!({
    text: TextComponent,
    role: RoleComponent,
    task: TaskComponent,
    hint: HintComponent,
    document: DocumentComponent,
    Document: DocumentComponent,  # Capitalized version
    table: TableComponent,
    Table: TableComponent,  # Capitalized version
    img: ImageComponent,
    p: ParagraphComponent,
    example: ExampleComponent,
    input: InputComponent,
    output: OutputComponent,
    'output-format': OutputFormatComponent,
    'outputformat': OutputFormatComponent,
    list: ListComponent,
    item: ItemComponent,
    cp: CPComponent,
    'stepwise-instructions': StepwiseInstructionsComponent,
    'stepwiseinstructions': StepwiseInstructionsComponent,
    StepwiseInstructions: StepwiseInstructionsComponent,
    'human-message': HumanMessageComponent,
    'humanmessage': HumanMessageComponent,
    HumanMessage: HumanMessageComponent,
    qa: QAComponent,
    QA: QAComponent,
    let: LetComponent,
    Let: LetComponent,
    stylesheet: StylesheetComponent,
    Stylesheet: StylesheetComponent
  })
end
