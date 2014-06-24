TaxonWorks::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
 
  # Vetted / tested

  root 'dashboard#index'

  match '/dashboard', to: 'dashboard#index', via: :get
  match '/signin',  to: 'sessions#new',      via: :get
  match '/signout', to: 'sessions#destroy',  via: :delete
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

  resources :alternate_values
  resources :biocuration_classifications
  resources :citation_topics
  resources :citations
  resources :collecting_events do
    collection do
      get 'test'
    end

  end
  resources :collection_objects
  resources :collection_profiles
  resources :contents
  resources :controlled_vocabulary_terms
  resources :data_attributes
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
  resources :loan_items
  resources :loans
  resources :namespaces
  resources :notes
  resources :otu_page_layout_sections
  resources :otu_page_layouts
  resources :otus do
    collection do
      post 'search'
      get 'list'
   end
  end
  resources :people
  resources :public_contents
  resources :ranged_lot_categories
  resources :repositories
  resources :tagged_section_keywords
  resources :tags
  resources :taxon_determinations
  resources :taxon_names do
    collection do
      get 'auto_complete_for_taxon_names'
    end
  end

  resources :taxon_name_classifications
  resources :taxon_name_relationships

  match 'quick_verbatim_material_task', to: 'tasks/accessions/quick/verbatim_material#new', via: 'get' 
  post 'tasks/accessions/quick/verbatim_material/create' # , via: 'post'

  match 'build_biocuration_groups_task', to: 'tasks/controlled_vocabularies/biocuration#build_collection', via: 'get'
  match 'build_biocuration_group', to: 'tasks/controlled_vocabularies/biocuration#build_biocuration_group', via: 'post'

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
