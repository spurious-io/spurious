# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spurious/version'

Gem::Specification.new do |spec|
  spec.name          = "spurious"
  spec.version       = Spurious::VERSION
  spec.authors       = ["Steven Jack"]
  spec.email         = ["stevenmajack@gmail.com"]
  spec.summary       = %q{Spurious is a cli tool that interacts with the spurious server}
  spec.description   = %q{Spurious is a cli tool that interacts with the spurious server}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "spurious-server"
  spec.add_runtime_dependency "eventmachine"
  spec.add_runtime_dependency "timeout", "0.0.0"
end
