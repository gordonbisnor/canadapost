# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "canadapost"
  spec.version       = "0.0.3"
  spec.authors       = ["Gordon B. Isnor"]
  spec.email         = ["gordonbisnor@gmail.com"]
  spec.description   = %q{A basic gem to interface with the Canada POST REST API}
  spec.summary       = %q{Works with Ruby on Rails. Requires HTTParty. Currently only addressing the Get Rates endpoint.}
  spec.homepage      = "http://www.github.com/gordonbisnor/canadapost"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('httparty')

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

