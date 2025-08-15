# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "poml"
  spec.version       = "0.0.1"
  spec.authors       = ["Ghennadii Mirosnicenco"]
  spec.email         = ["linkator7@gmail.com"]

  spec.summary       = "POML interpreter"
  spec.description   = "poml is a Ruby gem that implements POML"
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
  spec.metadata["changelog_uri"] = spec.homepage

  # Runtime dependencies
  spec.add_dependency "rexml", "~> 3.2"
  spec.add_dependency "rubyzip", "~> 2.3"
end
