# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email_finder/version'

Gem::Specification.new do |spec|
  spec.name          = "email_finder"
  spec.version       = EmailFinder::VERSION

  spec.authors       = ["Jim Jones"]
  spec.email         = ["jim.jones1@gmail.com"]

  spec.summary       = %q{Finds the most probable email address for a given set of employees.}
  spec.description   = %q{Finds the most probable email address for a given set of employees for a specific domain name.}
  spec.homepage      = "https://www.github.com/aantix/email_finder"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'distributed_search'
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
