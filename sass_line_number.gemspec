# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sass_line_number/version'

Gem::Specification.new do |gem|
  gem.name          = "sass_line_number"
  gem.version       = SassLineNumber::VERSION
  gem.authors       = ["Adam Martinik"]
  gem.email         = ["a.martinik@gmail.com"]
  gem.description   = %q{Small extension for sass to add line number after filename}
  gem.summary       = %q{It is very annoying to debug large sass documents. This 'hack' can help you find quickly the right line on right file}
  gem.homepage      = "http://github.com/14113/sass_line_number"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "sass"
  gem.add_development_dependency "rake"
end
