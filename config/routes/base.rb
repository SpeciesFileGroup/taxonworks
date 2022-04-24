root 'dashboard#index'

match '/dashboard', to: 'dashboard#index', via: :get

match '/signin', to: 'sessions#new', via: :get
match '/signout', to: 'sessions#destroy', via: :delete
resources :sessions, only: :create

get 'soft_validations/validate' => 'soft_validations#validate', defaults: {format: :json}
post 'soft_validations/fix' => 'soft_validations#fix', defaults: {format: :json}

# Note singular 'resource'
resource :hub, controller: 'hub', only: [:index] do
  get '/', action: :index
  get 'order_tabs' # should be POST
  post 'update_tab_order'
  get 'tasks', defaults: {format: :json}
end

scope :metadata, controller: 'metadata', only: [:index] do
  get 'object_radial/', action: :object_radial, defaults: {format: :json}
  get 'object_navigation/:global_id', action: :object_navigation, defaults: {format: :json}
  get '(/:klass)', action: :index, defaults: {format: :json}
end

scope :annotations, controller: :annotations do
  get ':global_id/metadata', action: :metadata, defaults: {format: :json}
  get :types, defaults: {format: :json}
end

scope :graph, controller: :graph do
  get ':global_id/metadata', action: :metadata, defaults: {format: :json}
  get ':global_id/object', action: :object, as: :object_graph, defaults: {format: :json}
end

namespace :shared do
  scope :maintenance, controller: :maintenance do
    patch :reorder, {format: :json}
  end
end

resources :projects do
  collection do
    get 'list'
    get 'search'
    get 'autocomplete' 
  end

  member do
    get 'select'
    get 'settings_for'
    get 'recently_created_stats'
  end
end

scope :administration, controller: :administration do
  match '/', action: :index, as: 'administration', via: :get
  get 'user_activity'
  get 'data_overview'
  get 'data_health'
  get 'data_reindex'
  get 'data_class_summary'
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
  collection do
    post 'batch_create'
    get :autocomplete, defaults: {format: :json}
  end
  member do
    get 'recently_created_data'
    get 'recently_created_stats'
  end
end

match '/preferences', to: 'users#preferences', via: 'get', defaults: {format: :json}
match '/project_preferences', to: 'projects#preferences', via: 'get', defaults: {format: :json}

match '/signup', to: 'users#new', via: 'get'
get '/forgot_password', to: 'users#forgot_password', as: 'forgot_password'
post '/send_password_reset', to: 'users#send_password_reset', as: 'send_password_reset'
get '/password_reset/:token', to: 'users#password_reset', as: 'password_reset'
patch '/set_password/:token', to: 'users#set_password', as: 'set_password'

match '/papertrail', to: 'papertrail#index', via: :get
match '/papertrail/compare/', to: 'papertrail#compare', as: 'papertrail_compare', via: :get
match '/papertrail/:id', to: 'papertrail#show', as: 'paper_trail_version', via: :get
match '/papertrail/update/', to: 'papertrail#update', as: 'papertrail_update', via: :put

match '/favorite_page/:kind/:name', to: 'user_preferences#favorite_page', as: :favorite_page, via: :post
match '/unfavorite_page/:kind/:name', to: 'user_preferences#unfavorite_page', as: :unfavorite_page, via: :post

get '/crash_test/' => 'crash_test#index' unless Rails.env.production?

