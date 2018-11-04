source 'https://rubygems.org'

gem 'rack-cors', '~> 1.0.1', require: 'rack/cors'

ruby '2.5.1'

gem 'rake', '~> 12.0'
gem 'rails', '5.2.1'
gem 'pg', '~> 1.0' # 1.0 not compatible with 5.1.4
gem 'activerecord-postgis-adapter', '~> 5.2.1'

gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 4.0.0'

# gem 'json', '>= 2.1.0'

# System
gem 'thor', '~> 0.19.4' # See https://github.com/rails/rails/issues/27229
gem 'rubyzip', '~> 1.2.2'
gem 'daemons', '~> 1.2.6'
gem 'tzinfo-data', '~> 1.2018.4' 
gem 'psych', '~> 3.0.2' 
gem 'rmagick', '~> 2.16'

# Geo
gem 'ffi-geos', '~> 1.2.0'
# gem 'rgeo-shapefile', '~> 0.4.2'  # deprecated? not compatible- perhaps only used in
gem 'rgeo', '~> 1.1.1'
gem 'rgeo-geojson', '~> 2.0.0'
gem 'rgeo-proj4'
gem 'postgresql_cursor', '~> 0.6.1'

# API/controllers
gem 'rabl', '~> 0.13.1'
gem 'jbuilder', '~> 2.7'
gem 'responders', '~> 2.4' # Used?!

# Email
gem 'exception_notification', '~> 4.2.1'

# Models
gem 'bcrypt', '~> 3.1.11'
gem 'closure_tree', '~> 7.0'
gem 'delayed_job_active_record', '~> 4.1.3'
gem 'validates_timeliness', '~> 4.0.2'
gem 'paper_trail', '~> 10.0.1'
gem 'acts_as_list', '~> 0.9.12'
gem 'modularity', '~> 2.0.1' # Used!?
gem 'paperclip', '~> 6.1.0'
gem 'paperclip-meta', '~> 3.0'
gem 'shortener', '~> 0.8.0'

# javascript
gem 'sprockets-rails', '~> 3.2.0'
gem 'sprockets', '~> 3.7.1'
gem 'sprockets-es6', '~> 0.9.2', require: 'sprockets/es6'
gem 'webpacker', '>= 4.0.x'
gem 'uglifier', '~> 4.1.10'

gem 'jquery-rails', '~> 4.3.3'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'rails-jquery-autocomplete', '~> 1.0.3'

gem 'turbolinks', '~> 5.2.0'
gem 'jquery-turbolinks', '~> 2.1'

# BibTeX handling
gem 'csl', '~> 1.5.0'
gem 'bibtex-ruby', '~> 4.4.7'
gem 'citeproc-ruby', '~> 1.1.10'
gem 'csl-styles', '~> 1.0.1.8'
gem 'ref2bibtex', '~> 0.2.2'
# gem 'latex-decode', '~> 0.2.2'
gem 'pdf-reader', '~> 2.1'

# UI/UX
gem 'chartkick', '~> 3.0.1'
gem 'groupdate', '~> 4.0.1'
gem 'dropzonejs-rails', '~> 0.8.1'
gem 'kaminari', '~> 1.1.1'
gem 'best_in_place', '~> 3.1.1'
gem 'redcarpet', '~> 3.4'
gem 'sassc-rails', '~> 1.3.0'

# "Bio" and SFG gems
gem 'taxonifi', '0.4.0'
gem 'sqed', '0.4.4'
gem 'dwc-archive', '~> 1.0.1'
gem 'biodiversity', '~> 3.5.0'
gem 'ruby-units', '~> 2.3.0', require: 'ruby_units/namespaced'

# Minor Utils/helpers
gem 'awesome_print', '~> 1.8'
gem 'indefinite_article', '~> 0.2.4'
gem 'rainbow', '~> 3.0.0'
gem 'term-ansicolor', '~> 1.6' # DEPRECATED
gem 'chronic', '~> 0.10.2'
gem 'logical_query_parser'
gem 'logic_tools'

# Deploy, deprecated soon
gem 'capistrano-npm', '~> 1.0.2'

group :test, :development do
  gem 'faker', '~> 1.9.1'
  gem 'rspec-rails', '~> 3.6'
  gem 'rspec-activemodel-mocks', '~> 1.1.0'
#  gem 'inch', '~> 0.7.1', require: false, # security issue
  gem 'byebug', '~> 10.0', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'factory_bot_rails', '~> 4.11.0'
  gem 'selenium-webdriver', '~> 3.14'
  gem 'geckodriver-helper', '~> 0.21.0'
  gem 'prawn', '~> 2.2.2'
end

gem 'parallel_tests', group: [:development, :test]

group :development do
# gem 'tunemygc'
  gem 'ruby-prof', '~> 0.17.0'
  gem 'better_errors', '~> 2.3'
  gem 'binding_of_caller'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'guard-rspec', '~> 4.7.3', require: false

  gem 'web-console', '~> 3.7.0'
  gem 'rubocop', '~> 0.59.2'
  gem 'rubocop-rspec'
  gem 'brakeman', '~> 4.3.0', require: false
  gem 'seedbank', git: 'https://github.com/james2m/seedbank'
end

group :doc do
  gem 'sdoc', '~> 1.0', require: false 
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'coveralls', '~> 0.8.22', require: false
  gem 'capybara', '~> 3.9.0'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.4.1'
  gem 'vcr', '~> 4.0.0'
  gem 'database_cleaner', '~> 1.7.0'
  gem 'rails-controller-testing', '~> 1.0.2'

# gem 'simplecov', :require => false
# gem 'simplecov-rcov', :require => false
end

group :production do
  gem 'execjs', '~> 2.7.0'
  gem 'passenger', '~> 5.3.4'
end


