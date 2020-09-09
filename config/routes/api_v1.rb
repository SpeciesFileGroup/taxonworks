namespace :api, defaults: {format: :json} do

  namespace :v1 do

    # authentication free
    get '/', to: 'base#index'

    get :ping, controller: 'ping'
    get :pingz, controller: 'ping'

    # authenticated by user_token
    defaults authenticate_user: true do
      get '/user_authenticated', to: 'base#index'

      get '/sources', to: '/sources#api_index'
      get '/sources/:id', to: '/sources#api_show'
      get '/sources/autocomplete', to: '/sources#autocomplete'

      get '/people', to: '/people#api_index'
      get '/people/:id', to: '/people#api_show'
      get '/people/autocomplete', to: '/people#autocomplete'
    end

    # authenticated by project token
    defaults authenticate_project: true do
      get '/project_authenticated', to: 'base#index'
      # !@ may not be many things here, doesn't make a lot of sense?!
    end

    defaults authenticate_user: true, authenticate_project: true do
      # authenticated by user and project
      get '/both_authenticated', to: 'base#index'
    end

    defaults authenticate_user_or_project: true do
      get '/otus', to: '/otus#index'

      get '/downloads/:id', to: '/downloads#api_show'
      get '/downloads', to: '/downloads#api_index'
      get '/downloads/:id/file', to: '/downloads#api_file', as: :download_file

      get '/taxon_names', to: '/taxon_names#api_index'
      get '/taxon_names/autocomplete', to: '/taxon_names#autocomplete'
      get '/taxon_names/:id', to: '/taxon_names#api_show'

      get '/collection_objects', to: '/identifiers#api_index'
      get '/collection_objects/:id', to: '/identifiers#api_show'
      get '/collection_objects/autocomplete', to: '/identifiers#autocomplete'

      # get '/identifiers', to: '/identifiers#api_index'
      # get '/identifiers/:id', to: '/identifiers#api_show'
      # get '/identifiers/autocomplete', to: '/identifiers#autocomplete'

    end

    # Authenticate membership at the data controller level

    # Default response when no route matches
    match '/:path', to: 'base#not_found', via: :all
  end
end


