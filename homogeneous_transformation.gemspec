# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'homogeneous_transformation/version'

Gem::Specification.new do |spec|
  spec.name          = "homogeneous_transformation"
  spec.version       = HomogeneousTransformation::VERSION
  spec.authors       = ["Cory Crean"]
  spec.email         = ["cory.crean@gmail.com"]
  spec.description   = %q{Provides a HomogeneousTransformation class to convert back and forth between the representations of vectors in different reference frames}
  spec.summary       = %q{Provides a HomogeneousTransformation class}
  spec.homepage      = "https://github.com/ccrean/HomTran_ruby"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov", "~> 0.11.2"
  spec.add_development_dependency "simplecov-html", "~> 0.10.0"
  spec.add_runtime_dependency "unit_quaternion", ">= 0.0.5"
end
