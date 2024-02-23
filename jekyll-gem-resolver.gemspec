# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/gem_resolver/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-gem-resolver"
  spec.version       = Jekyll::GemResolver::VERSION
  spec.authors       = ["Lukas Waslowksi"]
  spec.email         = ["cr7pt0gr4ph7@gmail.com"]
  spec.description   = %q{Gem resolver plugin for Jekyll}
  spec.summary       = %q{Simple Jekyll plugin that enables including resources from non-Jekyll gems (primarily, but not limited to, SASS/SCSS files and static assets) into the site build.}
  spec.homepage      = "https://github.com/cr7pt0gr4ph7/jekyll-gem-resolver"
  spec.license       = "MIT"
  spec.metadata      = {
    "documentation_uri" => "https://github.com/cr7pt0gr4ph7/jekyll-gem-resolver",
    "source_code_uri"   => "https://github.com/cr7pt0gr4ph7/jekyll-gem-resolver"
  }

  spec.files         = [*Dir["lib/**/*.rb"], "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 3.0'
  spec.add_development_dependency 'jekyll', '~> 4.3.3'
  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency 'minitest'
end
