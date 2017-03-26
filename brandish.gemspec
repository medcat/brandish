# encoding: utf-8

# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "brandish/version"

Gem::Specification.new do |spec|
  spec.name          = "brandish"
  spec.version       = Brandish::VERSION
  spec.authors       = ["Jeremy Rodi"]
  spec.email         = ["me@medcat.me"]

  spec.summary       = "A markup language for compiling to different formats."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/medcat/brandish"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "hanami-helpers", "~> 0.5"
  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "commander", "~> 4.4"
  spec.add_dependency "listen", "~> 3.0"
  spec.add_dependency "sass", "~> 3.4"
  spec.add_dependency "yoga", "~> 0.4"
  spec.add_dependency "liquid", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.13"
  spec.add_development_dependency "rubocop", "~> 0.47"
end
