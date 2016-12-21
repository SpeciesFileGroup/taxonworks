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
    get 'order_tabs' # should be POST
    post 'update_tab_order'
  end

  resources :projects do
    concerns [:data_routes]
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

  resources :project_members, except: [:index, :show] do
    collection do
      get :many_new
      post :create_many
    end
  end

  resources :pinboard_items, only: [:create, :destroy] do
    collection do
      post 'update_position'
      post 'update_type_position'
    end
  end

  ### Below this point, please keep objects in alphabetical order ###

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

  resources :biological_associations do
    concerns [:data_routes]
  end

  resources :biological_associations_graphs do
    concerns [:data_routes]
  end

  resources :biological_relationships do
    concerns [:data_routes]
  end

  resources :character_states do
    # TODO
  end

  resources :citation_topics, only: [:create, :update, :destroy]

  resources :citations do # except: [:show]
    concerns [:data_routes]
  end

  resources :confidences do # , except: [:edit, :show]
    concerns [:data_routes]
  end

  resources :confidence_levels, only: [] do
    collection do
      get 'autocomplete'
    end
  end


  resources :collection_objects do
    concerns [:data_routes]
    member do
      get 'depictions'
      get 'containerize'
    end
    collection do
      get :preview_simple_batch_load # should be get
      post :create_simple_batch_load
    end
  end
  match 'collection_objects/by_identifier/:identifier', to: 'collection_objects#by_identifier', via: :get

  resources :collection_object_observations do
    concerns [:data_routes]
  end

  resources :collection_profiles do
    concerns [:data_routes]
  end
  match 'collection_profiles/swap_form_attribute_types/:collection_type', to: 'collection_profiles#swap_form_attribute_types', via: :get, method: :js

  resources :collecting_events do
    concerns [:data_routes]
    get :autocomplete_collecting_event_verbatim_locality, on: :collection
    member do
      get :card
    end
    # collection do
    #   post :preview_simple_batch_load # should be get
    #   post :create_simple_batch_load
    # end
  end

  resources :combinations, only: [:create, :edit, :update, :destroy, :new] do
    concerns [:data_routes]
  end

  resources :common_names do
    concerns [:data_routes]
  end

  resources :containers do # , only: [:create, :update, :destroy] do
    concerns [:data_routes]
  end

  resources :container_items, except: [:edit] do
    concerns [:data_routes]
  end

  resources :contents do
    concerns [:data_routes]
  end

  resources :controlled_vocabulary_terms do
    concerns [:data_routes]

    member do
      get 'tagged_objects'
    end
  end

  resources :data_attributes, except: [:show] do
    concerns [:data_routes]
  end

  resources :depictions do
    concerns [:data_routes]
  end

  resources :descriptors do
    concerns [:data_routes]
  end

  resources :documents do
    concerns [:data_routes]
  end

  resources :documentation do
    concerns [:data_routes]
  end

  resources :extracts do
    concerns [:data_routes]
  end
  
  resources :geographic_areas do
    concerns [:data_routes]
    collection do
      post 'display_coordinates'
      get 'display_coordinates', as: "getdisplaycoordinates"
    end
  end

  resources :gene_attributes do
    concerns [:data_routes]
  end

  resources :geographic_areas_geographic_items, except: [:index, :show]

  resources :geographic_area_types

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
    member do
      get 'extract(/:x/:y/:width/:height)', action: :extract
      get 'scale(/:x/:y/:width/:height/:new_width/:new_height)', action: :scale
      get 'scale_to_box(/:x/:y/:width/:height/:box_width/:box_height)', action: :scale_to_box
      get 'ocr(/:x/:y/:width/:height)', action: :ocr
    end
  end

  resources :keywords, only: [] do
    collection do
      get 'autocomplete'
    end
  end

  resources :languages, only: [] do
    collection do
      get 'autocomplete'
    end
  end

  resources :loans do
    concerns [:data_routes]
    member do
      get :recipient_form
    end
  end

  resources :loan_items do
    concerns [:data_routes]
  end

  resources :namespaces do
    concerns [:data_routes]

    collection do
      post :preview_simple_batch_load
      post :create_simple_batch_load
    end
  end

  resources :matrices do
    concerns [:data_routes]
  end

  resources :matrix_columns do
    concerns [:data_routes]
  end

  resources :matrix_rows do
    concerns [:data_routes]
  end

  resources :matrix_column_items do
    concerns [:data_routes]
  end

  resources :matrix_row_items do
    concerns [:data_routes]
  end
  
  resources :notes, except: [:show] do
    concerns [:data_routes]
  end

  resources :observations do
    concerns [:data_routes]
  end

  resources :otus do
    concerns [:data_routes]
    collection do
      post :preview_simple_batch_load # should be get
      post :create_simple_batch_load

      post :preview_simple_batch_file_load
      post :create_simple_batch_file_load
    end
  end

  resources :otu_page_layouts do
    collection do
      get :list
      get :lookup_topic, controller: 'topics'
    end
    member do
      get 'related'
    end
  end

  resources :origin_relationships do
    concerns [:data_routes]
  end

  resources :otu_page_layout_sections, only: [:create, :update, :destroy]

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

  resources :predicates, only: [] do
    collection do
      get 'autocomplete'
    end
  end

  resources :preparation_types do
    concerns [:data_routes]
  end

  resources :project_sources, only: [:index, :create, :destroy] do

    collection do
      get 'download'
      get 'list'
      get 'autocomplete'
      get 'search'
    end
  end

  resources :protocols do
    concerns [:data_routes]
  end

  resources :protocol_relationships do
    concerns [:data_routes]
  end

  resources :public_contents, only: [:create, :update, :destroy]

  resources :ranged_lot_categories do
    concerns [:data_routes]
  end

  resources :repositories do
    concerns [:data_routes]
  end

  # TODO: add exceptions
  resources :serials do
    concerns [:data_routes]
  end

  resources :serial_chronologies, only: [:create, :update, :destroy]

  resources :sequences do
    concerns [:data_routes]
  end

  resources :sequence_relationships do
    concerns [:data_routes]
  end
  
  resources :sources do
    concerns [:data_routes]
    collection do
      post :preview_bibtex_batch_load # should be get
      post :create_bibtex_batch_load
    end
  end

  resources :tags, except: [:edit, :show] do
    concerns [:data_routes]
  end

  resources :tagged_section_keywords, only: [:create, :update, :destroy]

  resources :taxon_determinations do
    concerns [:data_routes]
  end

  resources :taxon_names do
    concerns [:data_routes]
    collection do
      post :preview_simple_batch_load # should be get
      post :create_simple_batch_load
    end
    member do
      get :browse
    end
  end

  resources :taxon_name_classifications, except: [:show] do
    concerns [:data_routes]
  end

  resources :taxon_name_relationships do
    concerns [:data_routes]
  end

  resources :topics do
    collection do
      get :lookup_topic
      get 'get_definition/:id', action: 'get_definition'
      get :autocomplete
    end
  end

  resources :type_materials do
    concerns [:data_routes]
  end


  match '/favorite_page/:kind/:name', to: 'user_preferences#favorite_page', as: :favorite_page, via: :post
  match '/unfavorite_page/:kind/:name', to: 'user_preferences#unfavorite_page', as: :unfavorite_page, via: :post

  ### End of resources except user related located below scopes ###

  scope :tasks do

    scope :collection_objects do
      scope :filter, controller: 'tasks/collection_objects/filter' do
        get 'index', as: 'collection_objects_filter_task' #'index_area_and_date_task'
        get 'find', as: 'find_collection_objects_task' # 'find_area_and_date_task'
        get 'set_area'  , as: 'set_area_for_collection_object_filter'
        get 'set_date', as: 'set_date_for_collection_object_filter'
        get 'set_otu', as: 'set_otu_for_collection_object_filter'
        get 'download', action: 'download', as: 'download_collection_object_filter_result'
      end
    end

    # Scopes arranged alphabetically first level below :tasks

    scope :accessions do
      scope :report do
        scope :dwc, controller: 'tasks/accessions/report/dwc' do
          get '', action: :index, as: 'report_dwc_task'
          get 'row/:id', action: :row
          get :download, as: 'download_report_dwc_task'
        end
      end

      scope :breakdown do
        scope :sqed_depiction, controller: 'tasks/accessions/breakdown/sqed_depiction' do
          get 'todo_map', action: :todo_map, as: 'sqed_depiction_breakdown_todo_map_task'
          get ':id(/:namespace_id)', action: :index, as: 'sqed_depiction_breakdown_task'
          patch 'update/:id', action: :update, as: 'sqed_depiction_breakdown_update_task'
        end

        scope :buffered_data, controller: 'tasks/accessions/breakdown/buffered_data' do
          get ':id', action: :index, as: 'collection_object_buffered_data_breakdown_task'
          get 'thumb_navigator/:id', action: :thumb_navigator, as: 'collection_object_buffered_data_breakdown_thumb_navigator'
          patch 'update/:id', action: :update, as: 'collection_object_buffered_data_breakdown_update_task'
        end
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

      scope :simple, controller: 'tasks/accessions/quick/simple' do
        get 'new', as: 'simple_specimen_task'
        post 'create', as: 'create_simple_specimen_task'
        get 'collecting_events', format: :js
      end
    end

    scope :bibliography do
      scope :verbatim_reference, controller: 'tasks/bibliography/verbatim_reference' do
        get 'new', as: 'new_verbatim_reference_task'
        post 'preview', as: 'preview_verbatim_reference_task'
        post 'create_verbatim', as: 'create_verbatim_from_reference_task'
        post 'create_bibtex', as: 'create_bibtex_from_reference_task'
      end
    end

    scope :biological_associations do
      scope :dot, controller: 'tasks/biological_associations/dot' do
        get 'by_project/:project_id', action: :project_dot_graph, as: :biological_associations_dot_graph_task
      end
    end

    scope :contents, controller: 'tasks/content/preview' do
      get 'otu_content_for_layout/:otu_id', action: :otu_content_for_layout, as: 'preview_otu_content_for_layout'
      get ':otu_id', action: 'otu_content', as: 'preview_otu_content'
    end

    scope :controlled_vocabularies do
      scope :biocuration, controller: 'tasks/controlled_vocabularies/biocuration' do
        get 'build_collection', as: 'build_biocuration_groups_task'
        post 'build_biocuration_group', as: 'build_biocuration_group_task'

        post 'create_biocuration_group'
        post 'create_biocuration_class'
      end
    end

    scope :gis, controller: 'tasks/gis/report' do
      get 'report', action: 'new', as: 'gis_report_task'
      get 'download/:geographic_area_id', action: 'download', as: 'gis_report_download'
      post 'location_report_list'
      get 'location_report_list', action: 'repaint'
    end

    scope :gis, controller: 'tasks/gis/locality' do
      get 'nearby(/:id)', action: 'nearby', as: 'nearby_locality_task'
      get 'within(/:id)', action: 'within', as: 'within_locality_task'
      get 'new_list', action: 'new_list', as: 'new_list_task'
      post 'list' # , action: 'list', as: 'locatity_list_task'
    end

    scope :gis do
      scope :asserted_distribution, controller: 'tasks/gis/asserted_distribution' do
        get 'new', action: 'new', as: 'new_asserted_distribution_task'
        post 'create', action: 'create', as: 'create_asserted_distribution_task'
        get 'generate_choices'
      end
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

    scope :gis, controller: 'tasks/gis/drawable_map' do
      get 'drawn_area_select'
    end

    scope :gis, controller: 'tasks/gis/otu_distribution_data' do
      get 'otu_distribution_data/(:id)', action: 'show', as: 'otu_distribution_data_task'
      # get 'otu_distribution_data/((:id)/show2)', action: 'show2', as: 'otu_distribution_data_task2'

      get 'otu_distribution_data', action: 'show', as: 'first_otu_distribution_data_task'

      get 'taxon_name_distribution_data/:id', action: 'show_for_taxon_name', as: 'taxon_name_distribution_data_task'
    end

    scope :loans, controller: 'tasks/loans' do
      get 'complete/:id', action: :complete, as: 'loan_complete_task'

      get 'complete2/:id', action: :complete2, as: 'loan_complete2_task'

      # all technically Loan Routes
      post 'add_determination/:id', as: 'loan_add_determination', action: :add_determination
      post 'return_items/:id', as: 'loan_return_items', action: :return_items
      post 'update_status/:id', as: 'loan_update_status', action: :update_status
    end

    scope :nomenclature do
      scope :original_combination, controller: 'tasks/nomenclature/original_combination' do
        get 'edit/:taxon_name_id', action: :edit, as: 'edit_protonym_original_combination_task'
        patch 'update/:taxon_name_id', action: :update, as: 'update_protonym_original_combination_task'
      end

      scope :catalog do
        scope :basis, controller: 'tasks/nomenclature/catalog/basis' do
          get ':taxon_name_id', action: :index, as: 'basis_catalog_task'
        end
      end

      scope :browse, controller: 'tasks/nomenclature/browse' do
        get '(:id)', action: :index, as: 'browse_nomenclature_task'
      end

      scope :by_source, controller: 'tasks/nomenclature/by_source' do
        get '(:id)', action: :index, as: 'nomenclature_by_source_task'
      end

    end

    scope :people, controller: 'tasks/people/author' do
      get 'author', action: 'list', as: 'author_list_task'
      get 'source_list_for_author/:id', action: 'source_list_for_author', as: 'author_source_list_task'
    end

    scope :serials, controller: 'tasks/serials/similar' do
      get 'like(/:id)', action: 'like', as: 'similar_serials_task'
    end

    scope :usage, controller: 'tasks/usage/user_activity' do
      get ':id', action: 'report', as: 'user_activity_report_task'
    end

  end


  ### End of task scopes, user related below ###

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


  # TODO: Remove or rewrite endpoint implementation
  # get '/api/v1/taxon_names/' => 'api/v1/taxon_names#all'

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
  #     end  resources :gene_attributes
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  #
end

require_relative 'routes/api'
