source 'https://rubygems.org'
ruby '2.0.0'

# This is interesting.
# gem 'rack-webconsole', git: 'https://github.com/grappendorf/rack-webconsole.git'

win_os = false

if $LOAD_PATH[0] =~ /[A-Za-z]:[\/\\]/
  win_os = true
  os = 'Windows'
else
  os = '*nix/os x'
end

puts "\nBundling on #{os}(#{$LOAD_PATH[0]})."

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Database
gem 'mysql2', '0.3.11'

# Testing
# gem "factory_girl_rails", "~> 4.0"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :test do
  gem "rspec"
  gem 'coveralls', '~> 0.7', require: false
end

gem 'debugger', group: [:development, :test] if not win_os

group :development do 
  gem 'awesome_print'
end

gem "rspec-rails", :group => [:development, :test]

gem 'awesome_nested_set',  
  tag: '3.0.0.rc.2', 
  git: 'http://github.com/collectiveidea/awesome_nested_set.git'

# gem for decoding & encoding .bib files (BibTex bibliography files)
gem 'bibtex-ruby'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# 
