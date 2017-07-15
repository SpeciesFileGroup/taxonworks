source 'https://rubygems.org'


gem 'rack-cors', require: 'rack/cors'

ruby '~> 2.3'

gem 'rake', '~> 11.1'
gem 'rails', '~> 4.2.7.1'
gem 'pg', '~> 0.18.4'
gem 'activerecord-postgis-adapter', '~> 3.1.4'

gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 3.3.1'

# System
gem 'thor', '0.19.1' # See https://github.com/rails/rails/issues/27229
gem 'rubyzip', '~> 1.2.1'
gem 'daemons', '~> 1.2.4'
gem 'tzinfo-data', '~> 1.2017.2'
gem 'psych', '~> 2.1'
gem 'rmagick', '~> 2.16'

# Geo
gem 'ffi-geos', '~> 1.1.1'
gem 'rgeo-shapefile', '~> 0.4.1'
gem 'rgeo-geojson', '~> 0.4.3'
gem 'postgresql_cursor', '~> 0.6.1'

# API/controllers
gem 'rabl', '~> 0.13.0' # Used?!
gem 'jbuilder', '~> 2.5.0'
gem 'responders', '~> 2.4' # Used?!

# Email
gem 'exception_notification', '~> 4.2.1'
gem 'mail', '~> 2.7.0.rc1'

# Models 
gem 'bcrypt', '~> 3.1.11'
gem 'closure_tree', '~> 6.3.0'
gem 'delayed_job_active_record', '~> 4.1.2'
gem 'validates_timeliness', '~> 4.0.0'
gem 'paper_trail', '~> 4.0.2'
gem 'acts_as_list', '~> 0.8.0'
gem 'modularity', '~> 2.0.1' # Used!?
gem 'paperclip', '~> 4.3.6'
gem 'paperclip-meta', '~> 2.0'

# javascript 
gem 'sprockets-rails', '~> 3.2.0'
gem 'sprockets', '~> 3.0'
gem 'sprockets-es6', require: 'sprockets/es6'
gem 'webpacker', '~> 2.0'
gem 'uglifier', '~> 3.0.02'

gem 'jquery-rails', '~> 4.1.1'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'rails-jquery-autocomplete'
gem 'turbolinks', '~> 2.5.3'
gem 'jquery-turbolinks', '~> 2.1'

# BibTeX handling
gem 'csl', '~> 1.4.3'
gem 'bibtex-ruby', '~> 4.4.4'
gem 'citeproc-ruby', '~> 1.1.7'
gem 'csl-styles', '~> 1.0.1.8'
gem 'ref2bibtex', '~> 0.1.1'
gem 'latex-decode', '~> 0.2.2'
gem 'pdf-reader', '~> 2.0'

# UI/UX
gem 'chartkick', '~> 2.1.3'
gem 'groupdate', '~> 3.1.1'
gem 'dropzonejs-rails', '~> 0.7.3'
gem 'kaminari', '~> 0.17.0' 
gem 'best_in_place', '~> 3.1.1'
gem 'sass-rails', '~> 5.0.6'
gem 'redcarpet', '~> 3.3'

# "Bio" and SFG gems
gem 'taxonifi', '0.4.0'
gem 'sqed', '0.3.0'
gem 'dwc-archive', '~> 0.9.11'
gem 'biodiversity', '~> 3.4.1'

# Minor Utils/helpers
gem 'awesome_print', '~> 1.7'
gem 'indefinite_article', '~> 0.2.4'
gem 'rainbow', '~> 2.2.2'
gem 'term-ansicolor', '~> 1.4.0' # DEPRECATED
gem 'chronic', '~> 0.10'

# Deploy, deprecated soon
gem 'capistrano-npm', '~> 1.0.2'

group :test, :development do
  gem 'faker', '~> 1.6.1'
  gem 'rspec-rails', '~> 3.4'
  gem 'rspec-activemodel-mocks', '~> 1.0.2'
  gem 'inch', '~> 0.7'
  gem 'byebug', '~> 9.0.6', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'factory_girl_rails', '~> 4.7'
  gem 'selenium-webdriver', '~> 3.4.0' 
  gem 'geckodriver-helper', '~> 0.0.3'
end

group :development do
# gem 'tunemygc'
  gem 'ruby-prof', '~> 0.16.2'
  gem 'better_errors', '~> 2.0'
  gem 'binding_of_caller', '~> 0.7'
  gem 'spring-commands-rspec', '~> 1.0.2'
  gem 'guard-rspec', '~> 4.7', require: false
  gem 'parallel_tests', '~> 2.5.0'
  gem 'web-console', '~> 3.3.0'
  gem 'rubocop', '~> 0.49.0'
end

group :doc do
  gem 'sdoc', require: false 
end

group :test do
  gem 'rspec', '~> 3.4'
  gem 'coveralls', '~> 0.8.13', require: false
  gem 'capybara', '~> 2.14.1'
  gem 'timecop', '~> 0.8.1'
  gem 'webmock', '~> 2.1.0'
  gem 'vcr', '~> 3.0.0'
  gem 'database_cleaner', '~> 1.6.0'
# gem 'simplecov', :require => false
# gem 'simplecov-rcov', :require => false
end

group :production do
  gem 'execjs', '~> 2.7.0'
  gem 'passenger', '~> 5.1.5'
end


