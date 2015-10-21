TaxonWorks::Application.routes.draw do

  # Future consideration - move this to an engine, or include multiple draw files and include (you apparenlty
  # lose the autoloading update from the include in this case however) 
  scope :api, :defaults => { :format => :json } do
    get '/', controller: :api, action: :index, as: 'api'
    scope  '/v1' do
      get '/', to: 'api#index'
      get '/images/:id', to: 'images#show'
      get '/collection_objects/identified_by', to: 'collection_objects#identified_by'
      get '/otus/:id', to: 'otus#show'
    end
  end

end
