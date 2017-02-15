# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-plus/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-plus"
  spec.version       = JekyllPlus::VERSION
  spec.authors       = ["Ashwin Maroli"]
  spec.email         = ["ashmaroli@gmail.com"]

  spec.summary       = %q{A tool to simplify Jekyll experience with theme-gems.}
  spec.homepage      = "https://github.com/ashmaroli/jekyll-plus"
  spec.license       = "MIT"

  spec.metadata      = { "allowed_push_host" => "https://rubygems.org" }

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^((exe|lib)/|(LICENSE|README)((\.(txt|md|markdown)|$)))}i)
  end
  spec.bindir        = "exe"
  spec.executables   = "jekyll+"
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 3.4"
  spec.add_runtime_dependency "jekyll-data", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.14", ">= 1.14.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "cucumber", "~> 2.1"
end
