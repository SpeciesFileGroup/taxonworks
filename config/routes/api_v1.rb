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

      get '/identifiers', to: '/identifiers#api_index'
      get '/identifiers/:id', to: '/identifiers#api_show'
      get '/identifiers/autocomplete', to: '/identifiers#autocomplete'

      get '/collecting_events', to: '/collecting_events#api_index'
      get '/collecting_events/:id', to: '/collecting_events#api_show'
      get '/collecting_events/autocomplete', to: '/collecting_events#autocomplete'

      get '/collection_objects', to: '/collection_objects#api_index'
      get '/collection_objects/:id', to: '/collection_objects#api_show'
      get '/collection_objects/autocomplete', to: '/collection_objects#autocomplete'

      get '/biological_associations', to: '/biological_associations#api_index'
      get '/biological_associations/:id', to: '/biological_associations#api_show'
      get '/biological_associations/autocomplete', to: '/biological_associations#autocomplete'

      get '/citations', to: '/citations#api_index'
      get '/citations/:id', to: '/citations#api_show'
      get '/citations/autocomplete', to: '/citations#autocomplete'

      get '/asserted_distributions', to: '/asserted_distributions#api_index'
      get '/asserted_distributions/:id', to: '/asserted_distributions#api_show'
      get '/asserted_distributions/autocomplete', to: '/asserted_distributions#autocomplete'

      get '/observations', to: '/observations#api_index'
      get '/observations/:id', to: '/observations#api_show'
      get '/observations/autocomplete', to: '/_observations#autocomplete'

    end

    # Authenticate membership at the data controller level

    # Default response when no route matches
    match '/:path', to: 'base#not_found', via: :all
  end
end


