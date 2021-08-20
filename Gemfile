source 'https://rubygems.org'

gem 'rack-cors', '~> 1.1', require: 'rack/cors'

ruby '~> 2.7.0'

gem 'bundler', '~> 2.0'

gem 'rake', '~> 13.0'
gem 'rails', '~> 6.0'
gem 'pg', '~> 1.1'
gem 'activerecord-postgis-adapter', '~> 6.0'
gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 4.1.0'

# gem 'json', '>= 2.1.0'
gem 'rdf', '~> 3.0'

# System
gem 'thor', '~> 0.20.3'
gem 'rubyzip', '~> 2.3.0'
gem 'daemons', '~> 1.3.1'
gem 'tzinfo-data', '~> 1.2019' # , '>= 1.2019.3'
gem 'psych', '~> 3.1.0'
gem 'rmagick', '~> 4.2', '>= 4.2.2'

# Geo
gem 'ffi-geos', '~> 2.1.0'
# gem 'rgeo-shapefile', '~> 0.4.2'  # deprecated? not compatible- perhaps only used in
gem 'rgeo', '~> 2.2'
gem 'rgeo-geojson', '~> 2.1', '>= 2.1.1'
gem 'rgeo-proj4', '~> 3.0', '>= 3.0.1'
gem 'postgresql_cursor', '~> 0.6.1'

# translate for geo
gem 'gpx', '~> 1.0.0'

# API/controllers
gem 'jbuilder', '~> 2.7'
gem 'responders', '~> 3.0' # Used?!

# Email
gem 'exception_notification', '~> 4.4'

# Models
gem 'bcrypt', '~> 3.1.11'
gem 'closure_tree', '~> 7.0'

gem 'delayed_job_active_record', '~> 4.1.3'
gem 'validates_timeliness', '~> 4.1', '>= 4.1.1'
gem 'paper_trail', '~> 10.3', '>= 10.3.1'
gem 'acts_as_list', '~> 1.0'
gem 'modularity', '~> 2.0.1' # Used!?
gem 'paperclip', '~> 6.1.0'
gem 'paperclip-meta', '~> 3.0'
gem 'shortener', '~> 0.8.0'
gem 'rails_or', '~> 1.1.8'

# javascript
gem 'sprockets-rails', '~> 3.2.0'
gem 'sprockets', '~> 3.7.2' # TODO: Cannot use '~> 4.0' (app fails to initialize properly)
gem 'sprockets-es6', '~> 0.9.2', require: 'sprockets/es6'
gem 'webpacker', '~> 5.2', '>= 5.2.1'
gem 'uglifier', '~> 4.2'

gem 'jquery-rails', '~> 4.3.3'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'rails-jquery-autocomplete', '~> 1.0.3'

gem 'turbolinks', '~> 5.2.0'
gem 'jquery-turbolinks', '~> 2.1'

# BibTeX handling
gem 'csl', '~> 1.5.0'
gem 'bibtex-ruby', '~> 5.1.1'
gem 'citeproc-ruby', '~> 1.1.10'
gem 'csl-styles', '~> 1.0.1.8'
gem 'serrano', '~> 0.6.0'
# gem 'latex-decode', '~> 0.2.2'
gem 'pdf-reader', '~> 2.2'

# UI/UX
gem 'chartkick', '~> 3.4'
gem 'groupdate', '~> 4.2'
gem 'dropzonejs-rails', '~> 0.8.1'
gem 'kaminari', '~> 1.2.0'
gem 'best_in_place', '~> 3.1.1'
gem 'redcarpet', '~> 3.4'
gem 'sassc-rails', '~> 2.1.0'
gem 'waxy', '~> 0.1'
gem 'rgb', '~> 0.1'

# Drawing
gem 'rqrcode', github:'mjy/rqrcode', branch: 'taxonworks'
gem 'barby', '~> 0.6.8'

# "Bio" and SFG gems
gem 'taxonifi', '~> 0.5.5'
gem 'sqed', '0.6.0'
gem 'dwc-archive', '~> 1.1', '>= 1.1.2'
gem 'biodiversity', github: 'GlobalNamesArchitecture/biodiversity', branch: 'pipe_approach' # '~> 5.1', '>= 5.1.1'
gem 'ruby-units', '~> 2.3.0', require: 'ruby_units/namespaced'

# Global Names
gem 'gnfinder', '~> 0.11.0'

# Minor Utils/helpers
gem 'amazing_print', '~> 1.2.1'
gem 'indefinite_article', '~> 0.2.4'
gem 'rainbow', '~> 3.0.0'
gem 'term-ansicolor', '~> 1.6' # DEPRECATED
gem 'chronic', '~> 0.10.2'
gem 'logical_query_parser'
gem 'logic_tools'
gem 'chunky_png', '~> 1.3.11'
gem 'namecase', '~> 2.0'
gem 'zaru', '~> 0.3.0'

# www
gem 'wikidata-client', '~> 0.0.12', require: 'wikidata'

group :test, :development do
  gem 'faker', '~> 2.10'
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'rspec-activemodel-mocks', '~> 1.1.0'
  gem 'byebug', '~> 11.1', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'factory_bot_rails', '~> 5.1', '>= 5.1.1'
  gem 'webdrivers', '~> 4.5', require: false
  gem 'prawn', '~> 2.2.2'
end

gem 'parallel_tests', group: [:development, :test]

group :development do
# gem 'tunemygc'
  gem 'ruby-prof', '~> 1.2'
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'guard-rspec', '~> 4.7.3', require: false

  gem 'web-console', '~> 4.0', '>= 4.0.1'
  gem 'rubocop', '~> 0.76'
  gem 'rubocop-rails', '~> 2.4'
  gem 'rubocop-rspec', '~>1.38'
  gem 'rubocop-faker', '~> 0.2.0'
  gem 'rubocop-performance', '~> 1.10.2'
  gem 'brakeman', '~> 4.6', '>= 4.6.1', require: false
  gem 'seedbank', '~> 0.5.0'
end

group :doc do
  gem 'sdoc', '~> 1.0', require: false
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'codecov', '~> 0.5.1'
  gem 'simplecov', :require => false
  gem 'capybara', '~> 3.18'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.8' # , '>= 3.6.2'
  gem 'vcr', '~> 5.1'
  gem 'database_cleaner', '~> 1.8'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'os', '~> 1.0', '>= 1.0.1'
end

group :production do
  gem 'execjs', '~> 2.7.0'
  gem 'passenger', '~> 6.0.2'
end
