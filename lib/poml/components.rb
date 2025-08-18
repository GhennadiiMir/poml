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
require_relative 'components/formatting'
require_relative 'components/media'
require_relative 'components/utilities'
require_relative 'components/meta'
require_relative 'components/template'

module Poml
  # Update the component mapping after all components are loaded
  Components::COMPONENT_MAPPING.merge!({
    # Basic components
    text: TextComponent,
    poml: TextComponent,
    p: ParagraphComponent,
    
    # Formatting components
    b: BoldComponent,
    bold: BoldComponent,
    i: ItalicComponent,
    italic: ItalicComponent,
    u: UnderlineComponent,
    underline: UnderlineComponent,
    s: StrikethroughComponent,
    strike: StrikethroughComponent,
    strikethrough: StrikethroughComponent,
    span: InlineComponent,
    inline: InlineComponent,
    h: HeaderComponent,
    header: HeaderComponent,
    br: NewlineComponent,
    newline: NewlineComponent,
    code: CodeComponent,
    section: SubContentComponent,
    subcontent: SubContentComponent,
    
    # Media components
    audio: AudioComponent,
    
    # Instruction components
    role: RoleComponent,
    task: TaskComponent,
    hint: HintComponent,
    
    # Content components
    document: DocumentComponent,
    Document: DocumentComponent,  # Capitalized version
    
    # Data components
    table: TableComponent,
    Table: TableComponent,  # Capitalized version
    img: ImageComponent,
    obj: ObjectComponent,
    object: ObjectComponent,
    dataobj: ObjectComponent,
    'data-obj': ObjectComponent,
    webpage: WebpageComponent,
    
    # Example components
    example: ExampleComponent,
    input: InputComponent,
    output: OutputComponent,
    'output-format': OutputFormatComponent,
    'outputformat': OutputFormatComponent,
    examples: ExampleSetComponent,
    'example-set': ExampleSetComponent,
    introducer: IntroducerComponent,
    
    # List components
    list: ListComponent,
    item: ItemComponent,
    
    # Layout components
    cp: CPComponent,
    'captioned-paragraph': CPComponent,
    
    # Workflow components
    'stepwise-instructions': StepwiseInstructionsComponent,
    'stepwiseinstructions': StepwiseInstructionsComponent,
    StepwiseInstructions: StepwiseInstructionsComponent,
    'human-message': HumanMessageComponent,
    'humanmessage': HumanMessageComponent,
    HumanMessage: HumanMessageComponent,
    'user-msg': HumanMessageComponent,
    qa: QAComponent,
    QA: QAComponent,
    question: QAComponent,
    
    # Utility components
    'ai-msg': AiMessageComponent,
    'aimessage': AiMessageComponent,
    'system-msg': SystemMessageComponent,
    'systemmessage': SystemMessageComponent,
    'msg-content': MessageContentComponent,
    'message-content': MessageContentComponent,
    conversation: ConversationComponent,
    folder: FolderComponent,
    tree: TreeComponent,
    
    # Styling components
    let: LetComponent,
    Let: LetComponent,
    stylesheet: StylesheetComponent,
    Stylesheet: StylesheetComponent,
    
    # Meta components
    meta: MetaComponent,
    Meta: MetaComponent,
    
    # Template components
    include: IncludeComponent,
    Include: IncludeComponent,
    if: IfComponent,
    If: IfComponent,
    for: ForComponent,
    For: ForComponent
  })
end
