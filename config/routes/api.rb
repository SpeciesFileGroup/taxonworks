TaxonWorks::Application.routes.draw do

  # Future consideration - move this to an engine, or include multiple draw files and include (you apparenlty
  # lose the autoloading update from the include in this case however) 
  scope :api do
    get '/', controller: :api, action: :index, as: 'api'
    scope  '/v1' do
      get '/images/:id', to: 'images#show'
      get '/otus/:id', to: 'otus#show'
    end
  end

end
