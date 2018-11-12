get :ping, controller: 'ping',  defaults: { format: :json }
get :pingz, controller: 'ping',  defaults: { format: :json }

root 'dashboard#index'
match '/dashboard', to: 'dashboard#index', via: :get

match '/signin', to: 'sessions#new', via: :get
match '/signout', to: 'sessions#destroy', via: :delete
resources :sessions, only: :create

get 'soft_validations/validate' => 'soft_validations#validate', defaults: {format: :json}

# Note singular 'resource'
resource :hub, controller: 'hub', only: [:index] do
  get '/', action: :index
  get 'order_tabs' # should be POST
  post 'update_tab_order'
end

scope :annotations, controller: :annotations do
  get ':global_id/metadata', action: :metadata, defaults: {format: :json}
  get :types, defaults: {format: :json}
end

scope :graph, controller: :graph do
  get ':global_id/metadata', action: :metadata, defaults: {format: :json}
end

resources :projects do
#   concerns [:data_routes]
  member do
    get 'select'
    get 'settings_for'
    get 'stats'
    get 'recently_created_stats'
    get 'per_relationship_recent_stats/:relationship', action: :per_relationship_recent_stats, as: :per_relationship_recent_stats
  end
end

scope :administration, controller: :administration do
  match '/', action: :index, as: 'administration', via: :get
  get 'user_activity'
  get 'data_overview'
end

resources :project_members, except: [:index] do
  collection do
    get :many_new
    get :index, defaults: {format: :json}
    post :create_many

    get :clipboard, defaults: {format: :json}
    put :update_clipboard, defaults: {format: :json}
  end
end

resources :pinboard_items, only: [:create, :destroy, :update] do
  collection do
    post 'update_position'
    post 'update_type_position'
  end
end

scope :s do
  get ':id' => 'shortener/shortened_urls#show'
end

resources :users, except: :new do
  member do
    get 'recently_created_data'
    get 'recently_created_stats'
  end
end

match '/signup', to: 'users#new', via: 'get'
get '/forgot_password', to: 'users#forgot_password', as: 'forgot_password'
post '/send_password_reset', to: 'users#send_password_reset', as: 'send_password_reset'
get '/password_reset/:token', to: 'users#password_reset', as: 'password_reset'
patch '/set_password/:token', to: 'users#set_password', as: 'set_password'

match '/papertrail', to: 'papertrail#papertrail', via: :get
match '/papertrail/compare/', to: 'papertrail#compare', as: 'papertrail_compare', via: :get
match '/papertrail/:id', to: 'papertrail#show', as: 'paper_trail_version', via: :get
match '/papertrail/update/', to: 'papertrail#update', as: 'papertrail_update', via: :put

match '/favorite_page/:kind/:name', to: 'user_preferences#favorite_page', as: :favorite_page, via: :post
match '/unfavorite_page/:kind/:name', to: 'user_preferences#unfavorite_page', as: :unfavorite_page, via: :post

get '/crash_test/' => 'crash_test#index' unless Rails.env.production?
