source 'http://rubygems.org'
ruby '2.0.0'

gem 'rails', '4.0.2'

# PostgreSQL
gem 'pg', '~> 0.17.0'

# Postgis
gem 'activerecord-postgis-adapter'

# rgeo support
gem 'ffi-geos'
gem 'rgeo-shapefile'
gem 'rgeo-geojson'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.4'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

gem 'chronic', '~> 0.10'

gem 'awesome_nested_set',  
  tag: '3.0.0.rc.2', 
  git: 'http://github.com/collectiveidea/awesome_nested_set.git'

# BibTex handling
gem 'bibtex-ruby'
gem 'citeproc-ruby'

# Ordering records
gem 'acts_as_list'

# Versioning
gem 'paper_trail', '~> 3.0.0'

# DwC-A archive handling 
gem "dwc-archive", "~> 0.9.11"


# Password encryption
gem 'bcrypt-ruby', '~> 3.1.2'

# Build instances from factories
gem "factory_girl_rails", "~> 4.0"

group :test, :development do
  gem 'rspec-rails'
  gem 'debugger', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'awesome_print'
end

group :doc do
  gem 'sdoc', require: false # bundle exec rake doc:rails generates the API under doc/api.
end

group :test do
  gem "rspec"
  gem 'coveralls', '~> 0.7', require: false
end

group :development do 
  # gem 'foreigner', '~> 1.6' # conflicts with postgis adapter at present
end


