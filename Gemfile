source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '~> 4.2.6'
gem 'psych', '~> 2.0.16'
gem 'responders', '~> 2.0'

# PostgreSQL
gem 'pg', '~> 0.18.4'

# Postgis
gem 'activerecord-postgis-adapter', '~> 3.1.4'

# rgeo support
gem 'ffi-geos'
gem 'rgeo-shapefile', '~> 0.4.1'
gem 'rgeo-geojson', '~> 0.4.2'

# Redis support
#   http://redis.io/clients#ruby
gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 3.2.2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.4'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.0.4'
gem 'jquery-ui-rails', '~> 5.0.5'

gem 'rails-jquery-autocomplete'
gem 'best_in_place', '~> 3.1.0'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.5'
gem 'jquery-turbolinks', '~> 2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.4.1'
gem 'chronic', '~> 0.10'

# gem 'awesome_nested_set', '~> 3.0.3'

gem 'closure_tree', '~> 6.0.0'

# BibTex handling
gem 'csl', '~> 1.4.3' # git: 'https://github.com/inkshuk/csl-ruby'
gem 'bibtex-ruby', '~> 4.2.0'
gem 'citeproc-ruby', '~> 1.1.0'
gem 'csl-styles', '~> 1.0.1.6'

gem 'ref2bibtex', '~> 0.0.3'
gem 'latex-decode', '~> 0.2.2'

# gem 'anystyle-parser' # use when we stabilize

# Pagination
gem 'kaminari'

# File upload manager & image processor
gem 'paperclip', '~> 4.3.6'
gem 'paperclip-meta', '~> 2.0'

# Ordering records
gem 'acts_as_list'

# Versioning
gem 'paper_trail', '~> 4.0.0.rc'

# DwC-A archive handling
gem 'dwc-archive', '~> 0.9.11'

gem 'validates_timeliness', '~> 4.0.0'

# Password encryption
gem 'bcrypt', '~> 3.1.11'

# API view template engine
gem 'rabl', '~> 0.12.0'

gem 'rmagick', '~> 2.14'

gem 'exception_notification', '~> 4.1.2'

gem 'modularity', '~> 2.0.1'

gem 'colored', '~> 1.2'

gem 'chartkick', '~> 1.4.2'
gem 'groupdate', '~> 2.5.1'

gem 'dropzonejs-rails', '~> 0.7.3'

# SFG gems
gem 'taxonifi', '0.4.0'
gem 'sqed', '0.2.0'

group :test, :development do
  gem 'faker', '~> 1.6.1'
  gem 'rspec-rails', '~> 3.4'
  gem 'rspec-activemodel-mocks', '~> 1.0.2'
  gem 'inch', '~> 0.7'
  gem 'byebug', '~> 8.2.2', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'awesome_print'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'selenium-webdriver', '~> 2.52.0'
end

group :development do
  gem 'better_errors', '~> 2.0'
  gem 'binding_of_caller'
  gem 'spring-commands-rspec', '~> 1.0.2'
  gem 'guard-rspec', '~> 4.5', require: false
  gem 'parallel_tests', '~> 2.4.1'
  gem 'web-console', '~> 2.3'
  gem 'rubocop', '~> 0.37.2'
end

group :doc do
  gem 'sdoc', require: false # bundle exec rake doc:rails generates the API under doc/api.
end

group :test do
  gem 'rspec', '~> 3.4'
  gem 'coveralls', '~> 0.8.13', require: false
  gem 'capybara', '~> 2.1'
  gem 'timecop', '~> 0.8.0'
  gem 'webmock', '~> 1.24.1'
  gem 'vcr', '~> 3.0.0'
  gem 'database_cleaner', '~> 1.5.1'
# gem 'simplecov', :require => false
# gem 'simplecov-rcov', :require => false
end

group :production do
  gem 'execjs'
  gem 'passenger', '~> 5.0.26'
end

