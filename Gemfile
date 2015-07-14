source 'https://rubygems.org'
ruby '2.1.5'

gem 'rails', '~> 4.1.11'
gem 'psych', '~> 2.0.3'

# PostgreSQL
gem 'pg', '~> 0.18.1'

# Postgis
gem 'activerecord-postgis-adapter', '~> 2.2.0'

# rgeo support
gem 'ffi-geos'
gem 'rgeo-shapefile'
gem 'rgeo-geojson'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.4'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 3.1.3'
gem 'jquery-ui-rails', '~> 5.0.5'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.5'
gem 'jquery-turbolinks', '~> 2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
gem 'chronic', '~> 0.10'

gem 'awesome_nested_set', '~> 3.0.2' 

# BibTex handling
gem 'csl', '~> 1.4.3' # git: 'https://github.com/inukshuk/csl-ruby'
gem 'bibtex-ruby', '~> 4.0.12'
gem 'citeproc-ruby', '~> 1.1.0'
gem 'csl-styles', '~> 1.0.1.6'

gem 'ref2bibtex', '~> 0.0.3'
gem 'latex-decode', '~> 0.2.2'

# gem 'anystyle-parser' # use when we stabilize

# Pagination
gem 'kaminari'

# File upload manager & image processor
gem 'paperclip', '~> 4.3'
gem 'paperclip-meta', '~> 1.2.0'

# Ordering records
gem 'acts_as_list'

# Versioning
gem 'paper_trail', '~> 3.0.5'

# DwC-A archive handling 
gem 'dwc-archive', '~> 0.9.11'

gem 'validates_timeliness', '~> 3.0.14'

# Password encryption
gem 'bcrypt', '~> 3.1.7'

# API view template engine
gem 'rabl'

gem 'rmagick', '~> 2.14'

gem 'exception_notification'

gem 'modularity', '~> 2.0.1'

gem 'colored', '~> 1.2'

gem 'chartkick'
gem 'groupdate'

# SFG gems
gem 'taxonifi', '~> 0.3.4'
gem 'sqed', '~> 0.1.5'

group :test, :development do
  gem 'faker', '~> 1.4.3'
  gem 'rspec-rails', '~> 3.3'
  gem 'rspec-activemodel-mocks', '~> 1.0.1'
  gem 'inch'
  gem 'byebug', '~> 5.0', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'awesome_print'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'did_you_mean', '~> 0.9.4'
  gem 'selenium-webdriver', '~> 2.46.2'
end


group :development do
  gem 'better_errors', '~> 2.0'
  gem 'binding_of_caller'
  gem 'spring-commands-rspec', '~> 1.0.2'
  gem 'guard-rspec', '~> 4.5', require: false
  gem 'parallel_tests', '~> 1.5'
end

group :doc do
  gem 'sdoc', require: false # bundle exec rake doc:rails generates the API under doc/api.
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'coveralls', '~> 0.7', require: false
  gem 'capybara', '~> 2.1'
  gem 'timecop', '~> 0.7.1'
  gem 'webmock', '~> 1.21.0'
  gem 'vcr', '~> 2.9.2'
  gem 'database_cleaner', '~> 1.4'
# gem 'simplecov', :require => false
# gem 'simplecov-rcov', :require => false
end

group :production do
  gem 'execjs'
  gem 'passenger', '~> 5.0.5'
end

