# config/routes.rb
#Rails.application.eager_load!

# See initializer config/initializers/routing_draw.rb

# Routes are moved to config/routes.  
TaxonWorks::Application.routes.draw do
  draw :base
  draw :data
  draw :tasks
  draw :api_v1
  draw :annotations
end
