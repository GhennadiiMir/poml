# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "poml"
  spec.version       = "0.0.6"
  spec.authors       = ["Ghennadii Mirosnicenco"]
  spec.email         = ["linkator7@gmail.com"]

  spec.summary       = "Ruby implementation of POML (Prompt Oriented Markup Language)"
  spec.description   = <<~DESC
    POML is a Ruby gem that implements POML (Prompt Oriented Markup Language), 
    a markup language for structured prompt engineering. This is a Ruby port of 
    the original Microsoft POML library, providing comprehensive tools for creating, 
    processing, and rendering structured prompts with support for multiple output 
    formats including OpenAI Chat, LangChain, and Pydantic.
  DESC
  spec.homepage      = "https://github.com/GhennadiiMir/poml"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  # Include only essential files in the gem
  spec.files         = Dir[
    "lib/**/*.rb",
    "README.md", 
    "TUTORIAL.md",
    "LICENSE.txt",
    "examples/**/*",
    "media/logo-*.png"
  ].reject { |f| f.match(/debug|demo|test_comprehensive/) }
  
  spec.bindir        = "bin"
  spec.executables   = ["poml"]
  spec.require_paths = ["lib"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "#{spec.homepage}/blob/main/TUTORIAL.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Runtime dependencies
  spec.add_dependency "rexml", "~> 3.2"
  spec.add_dependency "rubyzip", "~> 2.3"
end
