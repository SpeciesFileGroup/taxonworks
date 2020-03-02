namespace :api, defaults: {format: :json} do

  namespace :v1 do

    # authentication free
    get '/', to: 'base#index'

    get :ping, controller: 'ping'
    get :pingz, controller: 'ping'

    # authenticated by user_token
    defaults authenticate_user: true do
      get '/user_authenticated', to: 'base#index'
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
      get '/downloads/:id/file', to: '/downloads#api_file'


      get '/taxon_names', to: '/taxon_names#api_index'
      get '/taxon_names/autocomplete', to: '/taxon_names#autocomplete'
      get '/taxon_names/:id', to: '/taxon_names#api_show'


    end

    # Authenticate membership at the data controller level

    # Default response when no route matches
    match '/:path', to: 'base#not_found', via: :all
  end
end


