source 'https://rubygems.org'
# only solutions for osx:
# rvm osx-ssl-certs update all
# https://rvm.io/support/fixing-broken-ssl-certificates
#
# if above doesn't work, try:
  # brew update # then
  # brew upgrade openssl

ruby '~> 2.3'

gem 'rake', '~> 11.1'

gem 'rails', '~> 4.2.7.1'
gem 'psych', '~> 2.0.16'
gem 'responders', '~> 2.0'

# PostgreSQL
gem 'pg', '~> 0.18.4'

gem 'biodiversity'

# Postgis
gem 'activerecord-postgis-adapter', '~> 3.1.4'

gem 'delayed_job_active_record'
gem 'daemons'

gem 'rubyzip', '~> 1.2.1'

gem 'postgresql_cursor'

# rgeo support
gem 'ffi-geos', '~> 1.1.1'
gem 'rgeo-shapefile', '~> 0.4.1'
gem 'rgeo-geojson', '~> 0.4.3'

# Redis support
#   http://redis.io/clients#ruby
gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 3.3.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'

gem 'sprockets-rails'
gem 'sprockets', '~> 3.0'
gem 'sprockets-es6', require: 'sprockets/es6'

# gem 'babel-transpiler'

gem 'webpacker'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 3.0.02'

# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.1.1'
gem 'jquery-ui-rails', '~> 5.0.5'

gem 'rails-jquery-autocomplete'
gem 'best_in_place', '~> 3.1.0'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
#
# See: https://gorails.com/episodes/upgrade-to-turbolinks-5 for notes 
# on updating.
# 
gem 'turbolinks', '~> 2.5.3'
gem 'jquery-turbolinks', '~> 2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5.0'
gem 'thor', '0.19.1' # See https://github.com/rails/rails/issues/27229
gem 'chronic', '~> 0.10'

gem 'closure_tree', '~> 6.3.0'

# BibTex handling
gem 'csl', '~> 1.4.3' # git: 'https://github.com/inkshuk/csl-ruby'
gem 'bibtex-ruby', '~> 4.4.2'
gem 'citeproc-ruby', '~> 1.1.4'
gem 'csl-styles', '~> 1.0.1.6'

gem 'ref2bibtex', '~> 0.0.3'
gem 'latex-decode', '~> 0.2.2'


# PDF
#
gem 'pdf-reader', '~> 2.0'

# gem 'anystyle-parser' # use when we stabilize

gem 'indefinite_article'

# Pagination
gem 'kaminari', '~> 0.17.0'

# File upload manager & image processor
gem 'paperclip', '~> 4.3.6'
gem 'paperclip-meta', '~> 2.0'

# Ordering records
gem 'acts_as_list', '~> 0.8.0'

gem 'capistrano-npm'

# Versioning
gem 'paper_trail', '~> 4.0.0.rc'

gem 'validates_timeliness', '~> 4.0.0'

# Password encryption
gem 'bcrypt', '~> 3.1.11'

# API view template engine
gem 'rabl', '~> 0.13.0'

gem 'rmagick', '~> 2.16'

gem 'exception_notification', '~> 4.2.1'

gem 'modularity', '~> 2.0.1'

gem 'rainbow' # perhaps a replacement for term-ansicolor

gem 'term-ansicolor', '~> 1.4.0' # '~> 1.3', '>= 1.3.2' # colorize doesn't seem to be working properly, using this instead.
gem 'awesome_print', '~> 1.7'

gem 'chartkick', '~> 2.1.3'
gem 'groupdate', '~> 3.1.1'
gem 'dropzonejs-rails', '~> 0.7.3'

# DwC-A archive handling
gem 'dwc-archive', '~> 0.9.11'

gem 'redcarpet', '~> 3.3'

# SFG gems
gem 'taxonifi', '0.4.0'
gem 'sqed', '0.2.4'


group :test, :development do
  gem 'faker', '~> 1.6.1'
  gem 'rspec-rails', '~> 3.4'
  gem 'rspec-activemodel-mocks', '~> 1.0.2'
  gem 'inch', '~> 0.7'
  gem 'byebug', '~> 9.0.5', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'factory_girl_rails', '~> 4.7'
  gem 'selenium-webdriver', '~> 2.53.4'
end

group :development do
#  gem 'tunemygc'
  gem 'ruby-prof'
  gem 'better_errors', '~> 2.0'
  gem 'binding_of_caller'
  gem 'spring-commands-rspec', '~> 1.0.2'
  gem 'guard-rspec', '~> 4.7', require: false
  gem 'parallel_tests', '~> 2.5.0'
  gem 'web-console', '~> 3.3.0'
  gem 'rubocop', '~> 0.46.0'
end

group :doc do
  gem 'sdoc', require: false # bundle exec rake doc:rails generates the API under doc/api.
end

group :test do
  gem 'rspec', '~> 3.4'
  gem 'coveralls', '~> 0.8.13', require: false
  gem 'capybara', '~> 2.11.0'
  gem 'timecop', '~> 0.8.1'
  gem 'webmock', '~> 2.1.0'
  gem 'vcr', '~> 3.0.0'
  gem 'database_cleaner', '~> 1.5.3'
# gem 'simplecov', :require => false
# gem 'simplecov-rcov', :require => false
end

group :production do
  gem 'execjs'
  gem 'passenger', '~> 5.0.30'
end

