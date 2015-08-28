TaxonWorks::Application.routes.draw do

  # All models that use data controllers should include this concern.
  # See http://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html to extend it to take options if need be.
  # TODO: This will have to be broken down to core_data_routes, and supporting_data_routes
  concern :data_routes do |options|
    collection do
      get 'download'
      get 'list'
      post 'batch_create'
      post 'batch_preview'
      get 'batch_load'
      get 'autocomplete'
      get 'search'
    end

    member do
      get 'related'
    end

  end

  root 'dashboard#index'

  match '/dashboard', to: 'dashboard#index', via: :get

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  resources :sessions, only: :create

  # Note singular 'resource' 
  resource :hub, controller: 'hub', only: [:index] do
    get '/', action: :index
    get 'order_tabs'
    post 'update_tab_order'
  end

  resources :projects do
    concerns [:data_routes]
    member do
      get 'select'
      get 'settings_for'
      get 'stats'
    end
  end

  scope :administration, controller: :administration do
    match '/', action: :index, as: 'administration', via: :get
    get 'user_activity'
    get 'data_overview'
  end

  # namespace :administration do
  #   get 'index'
  #   match '/administration', to: 'user_preferences#favorite_page', via: :post
  # end

  resources :project_members, except: [:index, :show]
  resources :pinboard_items, only: [:create, :destroy]

  resources :alternate_values, except: [:show] do
    concerns [:data_routes]
  end
  resources :asserted_distributions do
    concerns [:data_routes]

    collection do
      post :preview_simple_batch_load # should be get
      post :create_simple_batch_load
    end
  end
  resources :biocuration_classifications, only: [:create, :update, :destroy]
  resources :citation_topics, only: [:create, :update, :destroy]
  resources :citations, except: [:show] do
    concerns [:data_routes]
  end
  resources :collecting_events do
    concerns [:data_routes]
  end
  resources :collection_objects do
    concerns [:data_routes]
    member do
      get 'depictions'
    end
  end
  resources :collection_profiles do
    collection do
      get 'list'
    end
  end

  resources :collection_object_observations do
    concerns [:data_routes]
  end

  resources :containers, only: [:create, :update, :destroy]
  resources :container_items, only: [:create, :update, :destroy]

  resources :contents do
    concerns [:data_routes]
  end

  resources :controlled_vocabulary_terms do
    concerns [:data_routes]
  end

  resources :predicates, only: [] do
    collection do
      get 'autocomplete'
    end
  end

  resources :languages, only: [] do
    collection do
      get 'autocomplete'
    end
  end

  resources :keywords, only: [] do
    collection do
      get 'autocomplete'
    end
  end


  resources :combinations, only: [:create, :edit, :update, :destroy, :new] do
    concerns [:data_routes]
  end

  resources :data_attributes, except: [:show] do
    concerns [:data_routes]
  end

  resources :depictions do
    concerns [:data_routes]
  end

  resources :geographic_area_types
  resources :geographic_areas do
    concerns [:data_routes]
    collection do
      post 'display_coordinates'
      get 'display_coordinates', as: "getdisplaycoordinates"
    end
  end
  resources :geographic_areas_geographic_items, except: [:index, :show]
  resources :geographic_items


  resources :georeferences, only: [:index, :destroy, :new, :show, :edit] do
    concerns [:data_routes]
  end

  namespace :georeferences do
    resources :geo_locates, only: [:new, :create]
    resources :google_maps, only: [:new, :create]
    # verbatim_data
  end

  resources :identifiers, except: [:show] do
    concerns [:data_routes]
  end
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
  resources :notes, except: [:show] do
    concerns [:data_routes]
  end

  resources :otu_page_layout_sections, only: [:create, :update, :destroy]

  resources :topics do
    collection do
      get :lookup_topic
    end
  end

  resources :otu_page_layouts do
    collection do
      get :list
      get :lookup_topic, controller: 'topics'
    end
  end

  resources :otus do
    concerns [:data_routes]
    collection do
      post :preview_simple_batch_load # should be get
      post :create_simple_batch_load
    end
  end

  resources :people do
    concerns [:data_routes]
    member do
      get :roles
      get :details
    end
    collection do
      get :lookup_person
    end
  end

  resources :preparation_types do
    concerns [:data_routes]
  end

  resources :public_contents, only: [:create, :update, :destroy]

  # resources :ranged_lot_categories
  resources :ranged_lot_categories do
    concerns [:data_routes]
  end

  resources :repositories do
    concerns [:data_routes]
  end
  resources :serial_chronologies, only: [:create, :update, :destroy]

  # TODO: add exceptions 
  resources :serials do
    concerns [:data_routes]
  end

  resources :sources do
    concerns [:data_routes]
    collection do
      post :preview_bibtex_batch_load # should be get
      post :create_bibtex_batch_load
    end
  end

  resources :tagged_section_keywords, only: [:create, :update, :destroy]
  resources :tags, except: [:edit, :show] do
    concerns [:data_routes]
  end

  resources :taxon_determinations do
    concerns [:data_routes]
  end

  resources :taxon_names do
    concerns [:data_routes]

    collection do
      post :preview_simple_batch_load # should be get
      post :create_simple_batch_load
    end
  end

  resources :taxon_name_classifications, except: [:show] do
    concerns [:data_routes]
  end

  resources :taxon_name_relationships do
    concerns [:data_routes]
  end

  resources :type_materials do
    concerns [:data_routes]
  end

  match '/favorite_page', to: 'user_preferences#favorite_page', via: :post
  match '/remove_favorite_page', to: 'user_preferences#remove_favorite_page', via: :post

  scope :tasks do
    scope :nomenclature do
      scope :original_combination, controller: 'tasks/nomenclature/original_combination' do
        get 'edit/:taxon_name_id', action: :edit, as: 'edit_protonym_original_combination_task'
        patch 'update/:taxon_name_id', action: :update, as: 'update_protonym_original_combination_task'
      end
    end

    scope :gis, controller: 'tasks/gis/locality' do
      get 'nearby/:id', action: 'nearby', as: 'nearby_locality_task'
      get 'update/:id', action: 'update', as: 'update_locality_task'
      get 'within/:id', action: 'within', as: 'within_locality_task'
    end

    scope :gis, controller: 'tasks/gis/asserted_distribution' do
      get 'new', action: 'new', as: 'new_asserted_distribution_task'
      post 'create', action: 'create', as: 'create_asserted_distribution_task'
      get 'generate_choices'
    end

    scope :gis, controller: 'tasks/gis/draw_map_item' do
      get 'new_map_item', action: 'new', as: 'new_draw_map_item_task'
      post 'create_map_item', action: 'create', as: 'create_draw_map_item_task'
      get 'collect_item', as: 'collect_draw_item_task'
    end

    scope :gis, controller: 'tasks/gis/match_georeference' do
      get 'match_georeference', action: 'index', as: 'match_georeference_task'
      get 'filtered_collecting_events'
      get 'recent_collecting_events'
      get 'tagged_collecting_events'
      get 'drawn_collecting_events'

      get 'filtered_georeferences'
      get 'recent_georeferences'
      get 'tagged_georeferences'
      get 'drawn_georeferences'

      post 'batch_create_match_georeferences'
    end

    scope :gis, controller: 'tasks/gis/otu_distribution_data' do
      get 'otu_distribution_data/(:id)', action: 'show', as: 'otu_distribution_data_task'
      # get 'otu_distribution_data/((:id)/show2)', action: 'show2', as: 'otu_distribution_data_task2'

      get 'otu_distribution_data', action: 'show', as: 'first_otu_distribution_data_task'

      get 'taxon_name_distribution_data/:id', action: 'show_for_taxon_name', as: 'taxon_name_distribution_data_task'
    end

    scope :serials, controller: 'tasks/serials/similar' do
      get 'like/:id', action: 'like', as: 'similar_serials_task'
      post 'update/:id', action: 'update', as: 'update_serial_find_task'
      get 'find', as: 'find_similar_serials_task'
      post 'find', as: 'return_similar_serials_task'
    end

    scope :usage, controller: 'tasks/usage/user_activity' do
      get ':id', action: 'report', as: 'user_activity_report_task'
    end

    scope :accessions do

      scope :breakdown do
        scope :depiction, controller: 'tasks/accessions/breakdown/depiction' do
          get ':depiction_id', action: :index, as: 'depiction_breakdown_task'
          post :breakdown, action: :breakdown, as: 'depiction_breakdown_create_task'
        end

        # scope :sqed, controller: 'tasks/accessions/breakdown/sqed' do
        #   get 'index/:depiction_id', action: :index, as: 'sqed_breakdown_task'
        # end
      end

      scope :verify do
        scope :material, controller: 'tasks/accessions/verify/material' do
          get 'index/:by', action: :index, as: 'verify_accessions_task'
        end
      end

      scope :quick, controller: 'tasks/accessions/quick/verbatim_material' do
        get 'new', as: 'quick_verbatim_material_task'
        post 'create', as: 'create_verbatim_material_task'
      end

      scope :imaged, controller: 'tasks/accessions/imaged/associate' do
        get 'new', as: 'imaged_material_task'
        post 'create', as: 'create_imaged_material_task'
      end

    end

    scope :bibliography do
      scope :verbatim_reference, controller: 'tasks/bibliography/verbatim_reference' do
        get 'new', as: 'new_verbatim_reference_task'
        post 'create', as: 'create_verbatim_reference_task'
      end
    end

    scope :controlled_vocabularies do
      scope :biocuration, controller: 'tasks/controlled_vocabularies/biocuration' do
        get 'build_collection', as: 'build_biocuration_groups_task'
        post 'build_biocuration_group', as: 'build_biocuration_group_task'

        post 'create_biocuration_group'
        post 'create_biocuration_class'

      end
    end
  end

  resources :users, except: :new
  match '/signup', to: 'users#new', via: 'get'
  get '/forgot_password', to: 'users#forgot_password', as: 'forgot_password'
  post '/send_password_reset', to: 'users#send_password_reset', as: 'send_password_reset'
  get '/password_reset/:token', to: 'users#password_reset', as: 'password_reset'
  patch '/set_password/:token', to: 'users#set_password', as: 'set_password'

  match '/papertrail', to: 'papertrail#papertrail', via: :get
  match '/papertrail/:id', to: 'papertrail#show', as: 'paper_trail_version', via: :get

  # API STUB
  get '/api/v1/taxon_names/' => 'api/v1/taxon_names#all'

  get '/crash_test/' => 'crash_test#index' unless Rails.env.production?

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
  #
end
