TaxonWorks::Application.routes.draw do

  # Future consideration - move this to an engine, or include multiple draw files and include (you apparenlty
  # lose the autoloading update from the include in this case however)
  scope :api, :defaults => { :format => :json }, :constraints => { id: /\d+/ } do
    get '/', controller: :api, action: :index, as: 'api'
    scope  '/v1' do
      get '/', to: 'api#index'
      get '/images/:id', to: 'images#show', as: 'api_v1_image'
      get '/collection_objects/:id/images', to: 'collection_objects#images', as: 'api_v1_collection_object_images'
      get '/collection_objects/:id/geo_json', to: 'collection_objects#geo_json', as: 'api_v1_collection_object_geo_json'
      get '/collection_objects/by_identifier/:identifier', to: 'collection_objects#by_identifier'
      # get '/otus/:id', to: 'otus#show'
      # TODO: With the separation of images and geo_json, this path is no longer required.
      get '/collection_objects/:id', to: 'collection_objects#show', as: 'api_v1_collection_object'
    end
  end

end
