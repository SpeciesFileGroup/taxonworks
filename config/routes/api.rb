TaxonWorks::Application.routes.draw do

  # Future consideration - move this to an engine, or include multiple draw files and include (you apparenlty
  # lose the autoloading update from the include in this case however) 
  scope :api, :defaults => { :format => :json }, :constraints => { id: /\d+/ } do
    get '/', controller: :api, action: :index, as: 'api'
    scope  '/v1' do
      get '/', to: 'api#index'
      get '/images/:id', to: 'images#show', as: 'api_v1_image'
      get '/collection_objects/:id', to: 'collection_objects#show', as: 'api_v1_collection_object'
      get '/collection_objects/by_identifier/:identifier', to: 'collection_objects#by_identifier'
      # get '/otus/:id', to: 'otus#show'
    end
  end

end
