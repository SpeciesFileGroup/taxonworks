TaxonWorks::Application.routes.draw do

  # Vetted / tested

  # All models that use data controllers should include this concern. 
  # See http://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html to extend it to take options if need be.
  # TODO: This will have to be broken down to core_data_routes, and supporting_data_routes
  concern :data_routes do |options|
    collection do
      get 'download'
      get 'list'
      post 'batch_create'
      post 'batch_preview'
      post 'search'
      get 'autocomplete'
    end
  end

  root 'dashboard#index'

  match '/dashboard', to: 'dashboard#index', via: :get

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  resources :sessions, only: :create

  match '/papertrail', to: 'papertrail#papertrail', via: :get

  resources :projects do
    concerns [:data_routes]
    member do
      get 'select'
      get 'settings_for'
    end
  end

  # Note singular 'resource' 
  resource :hub, controller: 'hub', only: [:index] do
    get '/', action: :index
    get 'order_tabs'
    post 'update_tab_order'
  end

  match '/favorite_page', to: 'user_preferences#favorite_page', via: :post
  match '/administration', to: 'administration#index', via: 'get'

  resources :project_members

  resources :pinboard_items, only: [:create, :destroy]

  #
  # Unvetted/not fully tested Stubbed
  # 

  get '/forgot_password', to: 'users#forgot_password', as: 'forgot_password'
  post '/send_password_reset', to: 'users#send_password_reset', as: 'send_password_reset'
  match '/password_reset/:token', to: 'users#password_reset', via: 'get', as: 'password_reset'

  resources :alternate_values, only: [:create, :update, :destroy]
  resources :asserted_distributions do
    concerns [:data_routes]
  end
  resources :biocuration_classifications, only: [:create, :update, :destroy]
  resources :citation_topics, only: [:create, :update, :destroy]
  resources :citations, except: [:new, :edit, :show]  do
    concerns [:data_routes]
  end
  resources :collecting_events do
    concerns [:data_routes]
    collection do
      get 'test'
    end
  end
  resources :collection_objects do
    concerns [:data_routes]
  end
  resources :collection_profiles do
    collection do
      get 'list'
    end
  end
  resources :containers, only: [:create, :update, :destroy]
  resources :container_items, only: [:create, :update, :destroy]
  resources :contents do
    concerns [:data_routes]
  end
  resources :controlled_vocabulary_terms do
    concerns [:data_routes]
  end
  resources :data_attributes, only: [:create, :update, :destroy, :index]
  resources :geographic_area_types
  resources :geographic_areas do
    concerns [:data_routes]
  end
  resources :geographic_areas_geographic_items
  resources :geographic_items
  resources :georeferences do
    collection do
      get 'list'
    end
  end
  resources :identifiers, only: [:create, :update, :destroy, :index]
  resources :images do
    concerns [:data_routes]
  end
  resources :loan_items, only: [:create, :update, :destroy]
  resources :loans do
    concerns [:data_routes]
  end
  resources :namespaces do
    concerns [:data_routes]
  end
  resources :notes, except: [:new, :edit, :show] do
    collection do
      get 'list'
    end
  end
  resources :otu_page_layout_sections, only: [:create, :update, :destroy]
  resources :otu_page_layouts
  resources :otus do
    concerns [:data_routes]
  end
  resources :people do
    concerns [:data_routes]
  end
  resources :public_contents, only: [:create, :update, :destroy]
  resources :ranged_lot_categories
  resources :repositories do
    concerns [:data_routes]
  end
  resources :serial_chronologies, only: [:create, :update, :destroy]
  resources :serials
  resources :sources do
    concerns [:data_routes]
  end
  resources :tagged_section_keywords, only: [:create, :update, :destroy]
  resources :tags, only: [:create, :update, :destroy, :index] do
    concerns [:data_routes]
  end
  resources :taxon_determinations do
    collection do
      get 'list'
    end
  end
  resources :taxon_names do
    concerns [:data_routes]
  end
  resources :taxon_name_classifications, only: [:create, :update, :destroy]
  resources :taxon_name_relationships do
    collection do
      get 'list'
    end
  end
  resources :type_materials do
    concerns [:data_routes]
  end

  match 'quick_verbatim_material_task', to: 'tasks/accessions/quick/verbatim_material#new', via: 'get'
  post 'tasks/accessions/quick/verbatim_material/create'

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
