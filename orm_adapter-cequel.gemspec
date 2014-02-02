# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orm_adapter/cequel/version'

Gem::Specification.new do |spec|
  spec.name          = "orm_adapter-cequel"
  spec.version       = OrmAdapterCequel::VERSION
  spec.authors       = ["Mat Brown"]
  spec.email         = ["mat.a.brown@gmail.com"]
  spec.description   = %q{ORM adapter for Cequel, the CQL3 ORM for Ruby}
  spec.summary       = %q{ORM adapter for Cequel}
  spec.homepage      = "https://github.com/cequel/orm_adapter-cequel"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb'] + Dir['[A-Z]*'] + Dir['spec/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'orm_adapter', '~> 0.5'
  spec.add_runtime_dependency 'cequel', '~> 1.0.0.rc2'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "rubocop"
end
