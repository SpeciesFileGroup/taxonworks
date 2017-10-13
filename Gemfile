source 'https://rubygems.org'

gem 'rack-cors', '~> 1.0.1', require: 'rack/cors'

ruby '2.4.2'

gem 'rake', '~> 12.0'
gem 'rails', '~> 5.1.3'
gem 'pg', '~> 0.21.0'
gem 'activerecord-postgis-adapter', '~> 5.0'

gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 4.0.0'

# System
gem 'thor', '~> 0.19.4' # See https://github.com/rails/rails/issues/27229
gem 'rubyzip', '~> 1.2.1'
gem 'daemons', '~> 1.2.4'
gem 'tzinfo-data', '~> 1.2017.2'
gem 'psych', '~> 2.2.4'
gem 'rmagick', '~> 2.16'

# Geo
gem 'ffi-geos', '~> 1.2.0'
gem 'rgeo-shapefile', '~> 0.4.2'
gem 'rgeo-geojson', '~> 0.4.3'
gem 'postgresql_cursor', '~> 0.6.1'

# API/controllers
gem 'rabl', '~> 0.13.1'
gem 'jbuilder', '~> 2.7'
gem 'responders', '~> 2.4' # Used?!

# Email
gem 'exception_notification', '~> 4.2.1'
gem 'mail', '~> 2.7.0.rc1'

# Models
gem 'bcrypt', '~> 3.1.11'
gem 'closure_tree', '~> 6.6'
gem 'delayed_job_active_record', '~> 4.1.2'
gem 'validates_timeliness', '~> 4.0.2'
gem 'paper_trail', '~> 7.1'
gem 'acts_as_list', '~> 0.9.7'
gem 'modularity', '~> 2.0.1' # Used!?
gem 'paperclip', '~> 5.1'
gem 'paperclip-meta', '~> 3.0'

# javascript
gem 'sprockets-rails', '~> 3.2.0'
gem 'sprockets', '~> 3.7.1'
gem 'sprockets-es6', '~> 0.9.2', require: 'sprockets/es6'
gem 'webpacker', '~> 3.0'
gem 'uglifier', '~> 3.2'

gem 'jquery-rails', '~> 4.3.1'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'rails-jquery-autocomplete', '~> 1.0.3'

gem 'turbolinks', '~> 5.0.1'
gem 'jquery-turbolinks', '~> 2.1'

# BibTeX handling
gem 'csl', '~> 1.4.5'
gem 'bibtex-ruby', '~> 4.4.4'
gem 'citeproc-ruby', '~> 1.1.7'
gem 'csl-styles', '~> 1.0.1.8'
gem 'ref2bibtex', '~> 0.1.1'
gem 'latex-decode', '~> 0.2.2'
gem 'pdf-reader', '~> 2.0'

# UI/UX
gem 'chartkick', '~> 2.2.4'
gem 'groupdate', '~> 3.2'
gem 'dropzonejs-rails', '~> 0.8.1'
# TODO: Resolve how area_and_date_helper invocations have to change to accomidate new kaminari @jrflood
gem 'kaminari', '~> 1.0.1'
gem 'best_in_place', '~> 3.1.1'
gem 'sass-rails', '~> 5.0.6'
gem 'redcarpet', '~> 3.4'

# "Bio" and SFG gems
gem 'taxonifi', '0.4.0'
gem 'sqed', '0.3.2'
gem 'dwc-archive', '~> 0.9.11'
gem 'biodiversity', '~> 3.4.2'
gem 'ruby-units', '~> 2.2.0', require: 'ruby_units/namespaced'

# Minor Utils/helpers
gem 'awesome_print', '~> 1.8'
gem 'indefinite_article', '~> 0.2.4'
gem 'rainbow', '~> 2.2.2'
gem 'term-ansicolor', '~> 1.6' # DEPRECATED
gem 'chronic', '~> 0.10.2'
gem 'logical_query_parser'
gem 'logic_tools'

# Deploy, deprecated soon
gem 'capistrano-npm', '~> 1.0.2'

group :test, :development do
  gem 'faker', '~> 1.8'
  gem 'rspec-rails', '~> 3.6'
  gem 'rspec-activemodel-mocks', '~> 1.0.3'
  gem 'inch', '~> 0.7.1'
  gem 'byebug', '~> 9.1.0', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'factory_girl_rails', '~> 4.8'
  gem 'selenium-webdriver', '~> 3.6'
  gem 'geckodriver-helper', '~> 0.0.3'
end

group :development do
# gem 'tunemygc'
  gem 'ruby-prof', '~> 0.16.2'
  gem 'better_errors', '~> 2.3'
  gem 'binding_of_caller'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'parallel_tests', '~> 2.16.0'
  gem 'web-console', '~> 3.5.1'
  gem 'rubocop', '~> 0.50.0'
  gem 'seedbank', github: 'james2m/seedbank'
end

group :doc do
  gem 'sdoc', '~> 0.4.2', require: false
end

group :test do
  gem 'rspec', '~> 3.6'
  gem 'coveralls', '~> 0.8.21', require: false
  gem 'capybara', '~> 2.15.1'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.0.1'
  gem 'vcr', '~> 3.0.3'
  gem 'database_cleaner', '~> 1.6.1'
  gem 'rails-controller-testing', '~> 1.0.2'

# gem 'simplecov', :require => false
# gem 'simplecov-rcov', :require => false
end

group :production do
  gem 'execjs', '~> 2.7.0'
  gem 'passenger', '~> 5.1.7'
end


