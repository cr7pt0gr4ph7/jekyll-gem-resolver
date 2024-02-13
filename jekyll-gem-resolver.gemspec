# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/gem_resolver/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-gem-resolver"
  spec.version       = Jekyll::GemResolver::VERSION
  spec.authors       = ["Lukas Waslowksi"]
  spec.email         = ["cr7pt0gr4ph7@gmail.com"]
  spec.description   = %q{Gem resolver for Jekyll}
  spec.summary       = %q{This plugin provides simple support for resolving paths relative to the directory of specific gems.}
  spec.homepage      = "https://github.com/cr7pt0gr4ph7/jekyll-gem-resolver"
  spec.license       = "MIT"

  spec.files         = [*Dir["lib/**/*.rb"], "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 3.0'
  spec.add_development_dependency 'jekyll', '~> 4.3.3'
  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
