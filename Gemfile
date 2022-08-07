source 'https://rubygems.org'

gem 'rack-cors', '~> 1.1', require: 'rack/cors'

ruby '>= 3.0', '< 3.2'

gem 'bundler', '~> 2.0'

gem 'rake', '~> 13.0'
gem 'rails', '~> 6.1'
gem 'pg', '~> 1.1'
gem 'activerecord-postgis-adapter', '~> 7.0'
gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 4.5'

# gem 'json', '>= 2.1.0'
gem 'rdf', '~> 3.0'

# System
gem 'thor', '~> 1.2'
gem 'rubyzip', '~> 2.3.0'
gem 'zip_tricks', '~> 5.6'
gem 'daemons', '~> 1.4.1'
gem 'tzinfo-data', '~> 1.2019' # , '>= 1.2019.3'
gem 'psych', '~> 3.3'
gem 'rmagick', '~> 4.2', '>= 4.2.2'
gem 'roo', '~> 2.8', '>= 2.8.3'
gem 'roo-xls', '~> 1.2'
gem 'net-smtp', '~> 0.3.1'
gem "matrix", "~> 0.4.2"

# Geo
gem 'ffi-geos', '~> 2.3.0'
# gem 'rgeo-shapefile', '~> 0.4.2'  # deprecated? not compatible- perhaps only used in
gem 'rgeo', '~> 2.2'
gem 'rgeo-geojson', '~> 2.1', '>= 2.1.1'
gem 'rgeo-proj4', '~> 3.0', '>= 3.0.1'
gem 'postgresql_cursor', '~> 0.6.1'

# translate for geo
gem 'gpx', github: 'LocoDelAssembly/gpx', branch: 'ruby3'

# API/controllers
gem 'jbuilder', '~> 2.7'
gem 'responders', '~> 3.0' # Used?!

# Email
gem 'exception_notification', '~> 4.4'

# Models
gem 'bcrypt', '~> 3.1.11'
gem 'closure_tree', '~> 7.0'

gem 'delayed_job_active_record', '~> 4.1.3'

# TODO: updating to 5.0 causes "NoMethodError: undefined method `has_attached_file' for Image:Class"
# This is likely not the real propegated error, see similar https://github.com/Shopify/bootsnap/issues/218
# version 6 beta out now
gem 'validates_timeliness', '~> 4.1', '>= 4.1.1'
gem 'paper_trail', '~> 12.0'
gem 'acts_as_list', '~> 1.0'
gem 'modularity', '~> 3.0.0' # TODO: Used!?
gem 'paperclip', github: 'LocoDelAssembly/paperclip', branch: 'migration-fix' # gem 'paperclip', '~> 6.1.0'
gem 'paperclip-meta', '~> 3.0' # TODO: kt-paperclip can be installed but because of this gem old paperclip is installed as well and deprecation warnings continue
gem 'shortener', '~> 0.8.0'
gem 'rails_or', '~> 1.1.8'

# javascript
gem 'sprockets-rails', '~> 3.2.0' # UPDATE TODO
gem 'sprockets', '~> 3.7.2' # TODO: Cannot use '~> 4.0' (app fails to initialize properly)
gem 'sprockets-es6', '~> 0.9.2', require: 'sprockets/es6'
gem 'uglifier', '~> 4.2'

gem 'jquery-rails', '~> 4.4'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'rails-jquery-autocomplete', '~> 1.0.3'

gem 'turbolinks', '~> 5.2.0'
gem 'jquery-turbolinks', '~> 2.1'
gem "shakapacker", '~>6.3'

# BibTeX handling
gem 'csl', '~> 1.6.0'
gem 'bibtex-ruby', '~> 6.0'
gem 'citeproc-ruby', '~> 1.1.10'
gem 'csl-styles', '~> 1.0.1.8'
gem 'serrano', github: 'LocoDelAssembly/serrano', branch: 'fixes' #gem 'serrano', '~> 1.0.0'
# gem 'latex-decode', '~> 0.2.2'
gem 'pdf-reader', '~> 2.2'

# UI/UX
gem 'chartkick', '~> 4.0'
gem 'groupdate', '~> 5.2'
gem 'dropzonejs-rails', '~> 0.8.1'
gem 'kaminari', '~> 1.2.0'
gem "best_in_place", git: "https://github.com/mmotherwell/best_in_place"
gem 'redcarpet', '~> 3.4'
gem 'sassc-rails', '~> 2.1.0'
gem 'waxy', '~> 0.1'
gem 'rgb', '~> 0.1'

# Drawing
gem 'rqrcode', github:'mjy/rqrcode', branch: 'taxonworks'
gem 'barby', '~> 0.6.8'
gem 'ruby-graphviz', '~> 1.2.5', require: false

# "Bio" and SFG gems
gem 'taxonifi', '~> 0.6.0'
gem 'sqed', '~>0.7.0'
gem 'dwc_agent', '~> 3.0'
gem 'dwc-archive', github: 'LocoDelAssembly/dwc-archive', branch: 'overhaul' # '~> 1.1', '>= 1.1.2'
gem 'biodiversity', github: 'GlobalNamesArchitecture/biodiversity', branch: 'pipe_approach' # '~> 5.1', '>= 5.1.1'
gem 'ruby-units', '~> 2.3.0', require: 'ruby_units/namespaced'

# Global Names
gem 'gnfinder', '~> 0.16'

# Minor Utils/helpers
gem 'amazing_print', '~> 1.4.0'
gem 'indefinite_article', '~> 0.2.4'
gem 'rainbow', '~> 3.0.0'
gem 'term-ansicolor', '~> 1.6' # DEPRECATED
gem 'chronic', '~> 0.10.2'
gem 'logical_query_parser'
gem 'logic_tools'
gem 'chunky_png', '~> 1.4.0'
gem 'namecase', '~> 2.0'
gem 'zaru', '~> 0.3.0'

# www
gem 'wikidata-client', github:'LocoDelAssembly/wikidata-client', branch: 'bump-dependencies', require: 'wikidata'

group :test, :development do
  gem 'faker', '~> 2.10'
  gem 'rspec-rails', '~> 5.0'
  gem 'rspec-activemodel-mocks', '~> 1.1.0'
  gem 'byebug', '~> 11.1', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'factory_bot_rails', '~> 6.2'
  gem 'webdrivers', '~> 5.0', require: false
  gem 'prawn', '~> 2.4.0'
  gem 'puma', '~> 5.5'
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
  gem 'rubocop', '~> 1.20'
  gem 'rubocop-rails', '~> 2.4'
  gem 'rubocop-rspec', '~>2.6'
  gem 'rubocop-faker', '~> 1.1'
  gem 'rubocop-performance', '~> 1.10'
  gem 'brakeman', '~> 5.1', '>= 4.6.1', require: false
  gem 'seedbank', '~> 0.5.0'
end

group :doc do
  gem 'sdoc', '~> 2.2.0', require: false
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'codecov', '~> 0.6.0'
  gem 'simplecov', :require => false
  gem 'capybara', '~> 3.18'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.8' # , '>= 3.6.2'
  gem 'vcr', '~> 6.0'
  gem 'database_cleaner', '~> 2.0'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'os', '~> 1.0', '>= 1.0.1'
end

group :production do
  gem 'execjs', '~> 2.8.1'
  gem 'passenger', '~> 6.0.2'
end
