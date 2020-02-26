# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'biodiversity/version'

Gem::Specification.new do |gem|
  gem.name          = 'biodiversity'
  gem.version       = Biodiversity::VERSION
  gem.homepage      = 'https://github.com/GlobalNamesArchitecture/biodiversity'
  gem.license       = 'MIT'
  gem.summary       = 'Parser of scientific names'
  gem.description   = 'Parsing tool for biodiversity informatics'
  gem.authors       = ['Dmitry Mozzherin']
  gem.email         = 'dmozzherin@gmail.com'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'ffi', '~> 1.11'

  gem.add_development_dependency 'bundler', '~> 2.0'
  gem.add_development_dependency 'byebug', '~> 11.0'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rspec', '~> 3.9'
  gem.add_development_dependency 'rubocop', '~> 0.76'
end
