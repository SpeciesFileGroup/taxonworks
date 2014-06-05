TaxonWorks::Application.routes.draw do
  resources :public_contents

  resources :contents

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
 
  # Vetted / tested

  root 'dashboard#index'

  match '/signin',  to: 'sessions#new',     via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  resources :sessions, only: :create
  
  resources :projects do 
    member do
      get 'select'
      get 'settings_for' 
    end
  end

  match '/hub', to: 'hub#index', via: 'get'


  # Stubbed
  match '/forgot_password', to: 'users#forgot_password', via: 'get'

  resources :biocuration_classifications
  resources :collecting_events do
    collection do
      get 'test'
    end

  end
  resources :collection_objects
  resources :controlled_vocabulary_terms
  resources :geographic_area_types
  resources :geographic_areas do
    collection do
      post 'search'
    end
  end
  resources :geographic_areas_geographic_items
  resources :geographic_items
  resources :georeferences
  resources :identifiers
  resources :namespaces
  resources :notes
  resources :otus do
    collection do
      post 'search'
      get 'list'
   end
  end
  resources :people
  resources :repositories
  resources :taxon_determinations
  resources :taxon_names
  resources :taxon_name_classifications
  resources :taxon_name_relationships

  get 'taxon_names/demo'
  get 'taxon_names/marilyn'
  
  get 'tasks/accessions/quick/verbatim_material/new'
  post 'tasks/accessions/quick/verbatim_material/create'

  resources :users, except: :new
  match '/signup', to: 'users#new', via: 'get'

  # API STUB
  get '/api/v1/taxon_names/' => 'api/v1/taxon_names#all'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
