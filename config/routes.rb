Rails.application.eager_load!

TaxonWorks::Application.routes.draw do

  get :ping, controller: 'ping',  defaults: { format: :json }
  get :pingz, controller: 'ping',  defaults: { format: :json }

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

  ### Data routes

  ### Below this point, please keep objects in alphabetical order ###

  resources :alternate_values, except: [:show, :new] do
    concerns [:data_routes]
  end
  match '/alternate_values/:global_id/metadata', to: 'alternate_values#metadata', via: :get, defaults: {format: :json} #  method: :json

  resources :asserted_distributions do
    concerns [:data_routes]
    collection do
      post :preview_simple_batch_load # should be get
      post :create_simple_batch_load
    end
  end

  resources :biocuration_classifications, only: [:create, :update, :destroy] do
    collection do
      get :index, defaults: {format: :json}
    end
  end

  resources :biological_associations do
    concerns [:data_routes]
  end

  resources :biological_associations_graphs do
    concerns [:data_routes]
  end

  resources :biological_relationships do
    concerns [:data_routes]
    collection do
      get :select_options, defaults: {format: :json}
    end
  end

  resources :character_states do
    concerns [:data_routes]
    member do
      get :annotations, defaults: {format: :json}
    end
  end

  resources :citation_topics, only: [:create, :update, :destroy]

  resources :citations do # except: [:show]
    concerns [:data_routes]
  end

  resources :confidences do # , except: [:edit, :show]
    concerns [:data_routes]
    collection do
      post :confidence_object_update
    end
  end

  resources :confidence_levels, only: [:index] do
    collection do
      get 'lookup'
      get 'autocomplete'
      get :select_options, defaults: {format: :json}
    end
  end

  resources :collection_objects do
    concerns [:data_routes]

    member do
      get 'depictions', constraints: {format: :html}
      get 'containerize'
    end

    collection do
      post :preview_castor_batch_load # should be get
      post :create_castor_batch_load # should be get
      post :preview_buffered_batch_load
      post :create_buffered_batch_load
      get :preview_simple_batch_load
      post :create_simple_batch_load
      get :select_options, defaults: {format: :json}
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
    concerns [:data_routes ]
    get :autocomplete_collecting_event_verbatim_locality, on: :collection
    member do
      get :card
    end

    collection do
      get :select_options, defaults: {format: :json}

      post :preview_castor_batch_load
      post :create_castor_batch_load
    end
  end

  resources :combinations, only: [:create, :edit, :update, :destroy, :new] do
    concerns [:data_routes]
    collection do
      get :index, defaults: {format: :json}
    end
    member do
      get :show, defaults: {format: :json}
    end
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
    collection do
      get :filter
    end
  end

  resources :controlled_vocabulary_terms do
    concerns [:data_routes]

    member do
      get 'tagged_objects'
      get 'select', defaults: {format: :json}
    end
  end

  resources :data_attributes, except: [:show] do
    concerns [:data_routes]
  end

  resources :depictions do
    concerns [:data_routes]
    collection do
      patch :sort
    end
  end

  resources :descriptors do
    concerns [:data_routes]
    member do
      get :annotations, defaults: {format: :json}
    end
    collection do
      post :preview_modify_gene_descriptor_batch_load
      post :create_modify_gene_descriptor_batch_load
      get :units
    end
  end

  resources :documentation do
    concerns [:data_routes]
    collection do
      patch :sort
    end
  end

  resources :documents do
    concerns [:data_routes]
  end

  resources :extracts do
    concerns [:data_routes]
  end

  resources :geographic_areas do
    concerns [:data_routes]
    collection do
      post 'display_coordinates' # TODO should not be POST
      get 'display_coordinates', as: 'getdisplaycoordinates'
      get :select_options, defaults: {format: :json}
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
    collection do
      get :identifier_types, {format: :json}
    end
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
      get :autocomplete
      get :lookup_keyword
      get :select_options, defaults: {format: :json}
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
    collection do
      post :batch_create
    end
  end

  resources :namespaces do
    concerns [:data_routes]

    collection do
      post :preview_simple_batch_load
      post :create_simple_batch_load
      get :select_options, defaults: {format: :json}
    end
  end


  match 'observation_matrices/row/', to: 'observation_matrices#row', via: :get, method: :json
  resources :observation_matrices do
    concerns [:data_routes]

    resources :observation_matrix_columns, shallow: true, only: [:index], defaults: {format: :json}
    resources :observation_matrix_rows, shallow: true, only: [:index], defaults: {format: :json}
    resources :observation_matrix_row_items, shallow: true, only: [:index], defaults: {format: :json}
    resources :observation_matrix_column_items, shallow: true, only: [:index], defaults: {format: :json}
  end

  resources :observation_matrix_columns, only: [:index, :show] do
    concerns [:data_routes]
    collection do
      patch 'sort', {format: :json}
    end
  end

  resources :observation_matrix_rows, only: [:index, :show] do
    concerns [:data_routes]
    collection do
      patch 'sort', {format: :json}
    end
  end

  resources :observation_matrix_column_items do
    concerns [:data_routes]
    collection do
      post :batch_create
    end
  end

  resources :observation_matrix_row_items do
    concerns [:data_routes]
    collection do
      post :batch_create
    end
  end

  resources :notes, except: [:show] do
    concerns [:data_routes]
  end

  resources :observations do
    concerns [:data_routes]
    member do
      get :annotations, defaults: {format: :json}
    end
  end

  resources :otus do
    concerns [:data_routes ]
    resources :biological_associations, shallow: true, only: [:index], defaults: {format: :json}
    resources :asserted_distributions, shallow: true, only: [:index], defaults: {format: :json}
    resources :common_names, shallow: true, only: [:index], defaults: {format: :json}

    resources :contents, only: [:index]
    collection do

      post :preview_data_attributes_batch_load
      post :create_data_attributes_batch_load

      post :preview_simple_batch_load # should be get (batch loader fix)
      post :create_simple_batch_load

      post :preview_simple_batch_file_load
      post :create_simple_batch_file_load

      post :preview_identifiers_batch_load
      post :create_identifiers_batch_load

      post :preview_data_attributes_batch_load
      post :create_data_attributes_batch_load

      get :select_options, defaults: {format: :json}
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

  match 'people/role_types', to: 'people#role_types', via: :get, method: :json
  resources :people do
    concerns [:data_routes]
    member do
      get :similar, defaults: {format: :json}
      get :roles
      get :details
      post :merge, defaults: {format: :json}
    end
  end

  resources :predicates, only: [] do
    collection do
      get 'autocomplete'
      get :select_options, defaults: {format: :json}
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
    collection do
      get :select_options, defaults: {format: :json}
    end
  end

  # TODO: add exceptions
  resources :serials do
    concerns [:data_routes]
  end

  resources :serial_chronologies, only: [:create, :update, :destroy]

  resources :sequences do
    concerns [:data_routes]

    collection do
      post :preview_genbank_batch_file_load
      post :create_genbank_batch_file_load

      post :preview_genbank_batch_load
      post :create_genbank_batch_load

      post :preview_primers_batch_load
      post :create_primers_batch_load
    end
  end

  resources :sequence_relationships do
    concerns [:data_routes]

    collection do
      post :preview_primers_batch_load
      post :create_primers_batch_load
    end
  end

  resources :sources do
    concerns [:data_routes]
    collection do
      post :preview_bibtex_batch_load # should be get
      post :create_bibtex_batch_load
      get :parse, defaults: {format: :json}
    end
  end

  resources :tags, except: [:edit, :show, :new] do
    concerns [:data_routes]
    collection do
      get :autocomplete
      post :tag_object_update
      post :batch_remove, defaults: {format: :json}
    end
  end
  get 'tags/exists', to: 'tags#exists', defaults: {format: :json}

  resources :tagged_section_keywords, only: [:create, :update, :destroy]

  resources :taxon_determinations do
    concerns [:data_routes]
  end

  resources :taxon_names do
    concerns [:data_routes]
    resources :otus, shallow: true, only: [:index], defaults: {format: :json}
    resources :taxon_name_classifications, shallow: true, only: [:index], defaults: {format: :json}

    # TODO, check
    resources :taxon_name_relationships, shallow: true, only: [:index], defaults: {format: :json}, param: :subject_taxon_name_id

    collection do
      get :select_options, defaults: {format: :json}
      post :preview_simple_batch_load # should be get
      post :create_simple_batch_load
      get :ranks, {format: :json}

      post :preview_castor_batch_load
      post :create_castor_batch_load

      get :parse, defaults: {format: :json}
    end

    member do
      get :browse
      get :original_combination, defaults: {format: :json}
    end
  end

  resources :taxon_name_classifications, except: [:show] do
    concerns [:data_routes]
    collection do
      get :taxon_name_classification_types
    end
    member do
      get :show, {format: :json}
    end
  end

  resources :taxon_name_relationships do
    concerns [:data_routes]
    collection do
      get :type_relationships, {format: :json}
      get :taxon_name_relationship_types, {format: :json}
    end
  end

  resources :topics, only: [:create] do
    collection do
      get :index, defaults: { format: :json }
      get :select_options, defaults: {format: :json}
      get 'get_definition/:id', action: 'get_definition'
      get :autocomplete
      get :lookup_topic
      get :list
    end
  end

  resources :type_materials do
    concerns [:data_routes]
    collection do
      get :type_types, {format: :json}
    end
  end


  # Generate shallow routes for annotations based on model properties, like
  # otu_citations GET /otus/:otu_id/citations(.:format) citations#index
  ApplicationEnumeration.data_models.each do |m|
    ::ANNOTATION_TYPES.each do |t|
      if m.send("has_#{t}?")
        n = m.model_name
        match "/#{n.route_key}/:#{n.param_key}_id/#{t}", to: "#{t}#index", as: "#{n.singular}_#{t}", via: :get, constraints: {format: :json}, defaults: {format: :json}
      end
    end
  end

  ### End of data resources ###

  scope :tasks do
    scope :descriptors do
      scope :new_descriptor, controller: 'tasks/descriptors/new_descriptor' do
        get '(:id)', action: :index, as: 'new_descriptor_task'
      end
    end

    scope :browse_annotations, controller: 'tasks/browse_annotations' do
      get 'index', as: 'browse_annotations_task'
    end

    scope :uniquify_people, controller: 'tasks/uniquify/people' do
      get 'index', as: 'uniquify_people_task'
    end

    scope :otus do
      scope :browse, controller: 'tasks/otus/browse' do
        get '/(:otu_id)', action: :index, as: 'browse_otus_task'
      end
    end

    scope :type_material do
      scope :edit_type_material, controller: 'tasks/type_material/edit_type_material' do
        get '/', as: 'edit_type_material_task', action: :index
      end
    end

    scope :observation_matrices do
      scope :new_matrix, controller: 'tasks/observation_matrices/new_matrix' do
        get 'observation_matrix_row_item_metadata', as: 'observation_matrix_row_item_metdata', defaults: {format: :json}
        get 'observation_matrix_column_item_metadata', as: 'observation_matrix_column_item_metdata', defaults: {format: :json}
        get '(:id)', action: :index, as: 'new_matrix_task'
      end

      scope :row_coder, controller: 'tasks/observation_matrices/row_coder' do
        get 'index', as: 'index_row_coder_task'
        get 'set', as: 'set_row_coder_task'
      end
    end

    scope :import do
      scope :dwca do
        scope :psu_import, controller: 'tasks/import/dwca/psu_import' do
          get 'index', as: 'psu_import_task'
          post 'do_psu_import', as: 'do_psu_import'
        end
      end
    end

    scope :loans do
      scope :edit_loan, controller: 'tasks/loans/edit_loan' do
        get 'loan_item_metadata', as: 'loan_item_metdata', defaults: {format: :json}
        get '(:id)', action: :index, as: 'edit_loan_task'
      end

      scope :overdue, controller: 'tasks/loans/overdue' do
        get 'index', as: 'overdue_loans_task'
      end
    end

    scope :citations do
      scope :otus, controller: 'tasks/citations/otus' do
        get 'index', as: 'cite_otus_task_task'
      end
    end

    scope :content do
      scope :editor, controller: 'tasks/content/editor' do
        get 'index', as: 'index_editor_task'
        get 'recent_topics', as: 'content_editor_recent_topics_task'
        get 'recent_otus', as: 'content_editor_recent_otus_task'
      end
    end

    scope :sources do
      scope :individual_bibtex_source, controller: 'tasks/sources/individual_bibtex_source' do
        get 'index', as: 'index_individual_bibtex_source_task'
      end

      scope :browse, controller: 'tasks/sources/browse' do
        get 'index', as: 'browse_sources_task'
        get 'find', as: 'find_sources_task'
      end
    end

    scope :collecting_events do
      scope :parse do
        scope :stepwise do
          scope :dates, controller: 'tasks/collecting_events/parse/stepwise/dates' do
            get 'index', as: 'dates_index_task'
            post 'update', as: 'dates_update_task'
            get 'skip', as: 'dates_skip'
            get 'similar_labels', as: 'dates_similar_labels'
            get 'save_selected', as: 'dates_save_selected'
          end

          scope :lat_long, controller: 'tasks/collecting_events/parse/stepwise/lat_long' do
            get 'index', as: 'collecting_event_lat_long_task'
            post 'update', as: 'lat_long_update'
            get 'skip', as: 'lat_long_skip'
            get 're_eval', as: 'lat_long_re_eval'
            get 'save_selected', as: 'lat_long_save_selected'
            get 'convert', as: 'lat_long_convert'
            get 'similar_labels', as: 'lat_long_similar_labels'
          end
        end
      end
    end

    scope :collection_objects do
      scope :browse, controller: 'tasks/collection_objects/browse' do
        get 'index', as: 'browse_collection_objects_task'
      end

      scope :filter, controller: 'tasks/collection_objects/filter' do
        get 'index', as: 'collection_objects_filter_task' #'index_area_and_date_task'
        get 'find', as: 'find_collection_objects_task' # 'find_area_and_date_task'
        get 'set_area'  , as: 'set_area_for_collection_object_filter'
        get 'set_date', as: 'set_date_for_collection_object_filter'
        get 'set_otu', as: 'set_otu_for_collection_object_filter'
        get 'set_id_range', as: 'set_id_range_for_collection_object_filter'
        get 'set_user_date_range', as: 'set_user_date_range_for_collection_object_filter'
        get 'get_dates_of_type', as: 'get_dates_type_of_for_collection_object_filter'
        # get 'get_updated_at', as: 'get_updated_at_for_collection_object_filter'
        get 'download', action: 'download', as: 'download_collection_object_filter_result'
        post 'tag_all', action: 'tag_all', as: 'tag_all_collection_object_filter_result',  defaults: {format: :json}
      end
    end

    scope :otus do
      scope :filter, controller: 'tasks/otus/filter' do
        get 'index', as: 'otus_filter_task' #'index_area_and_date_task'
        get 'find', as: 'find_otus_task' # 'find_area_and_date_task'
        get 'set_area', as: 'set_area_for_otu_filter'
        get 'set_author', as: 'set_author_for_otu_filter'
        get 'set_nomen', as: 'set_nomen_for_otu_filter'
        get 'set_verbatim', as: 'set_verbatim_for_otu_filter'
        get 'download', action: 'download', as: 'download_otus_filter_result'
      end
    end

    # Scopes arranged alphabetically first level below :tasks

    scope :accessions do
      scope :comprehensive, controller: 'tasks/accessions/comprehensive' do
        get 'index', as: 'comprehensive_collection_object_task'
      end

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

    scope :gis, controller: 'tasks/gis/locality' do
      get 'nearby(/:id)', action: 'nearby', as: 'nearby_locality_task'
      get 'within(/:id)', action: 'within', as: 'within_locality_task'
      get 'new_list', action: 'new_list', as: 'new_list_task'
      post 'list' # , action: 'list', as: 'locatity_list_task'
    end

    scope :gis do
      scope :geographic_area_lookup, controller: 'tasks/gis/geographic_area_lookup' do
        get 'index', as: 'geographic_area_lookup_task'
        get 'resolve', as: 'geographic_area_lookup_resolve_task', format: :js
      end

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
#      get 'otu_distribution_data', action: 'show', as: 'first_otu_distribution_data_task'

      get 'taxon_name_distribution_data/:id', action: 'show_for_taxon_name', as: 'taxon_name_distribution_data_task'
    end

    scope :nomenclature do
      scope :new_combination, controller: 'tasks/nomenclature/new_combination' do
        get 'index', as: 'new_combination_task'
      end

      scope :new_taxon_name, controller: 'tasks/nomenclature/new_taxon_name' do
        get '(:id)', action: :index, as: 'new_taxon_name_task'
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

  scope :s do
    get ':id' => 'shortener/shortened_urls#show'
  end

  # constraints subdomain: 's' do
  #   get '/:id' => "shortener/shortened_urls#show"
  # end

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

  match '/favorite_page/:kind/:name', to: 'user_preferences#favorite_page', as: :favorite_page, via: :post
  match '/unfavorite_page/:kind/:name', to: 'user_preferences#unfavorite_page', as: :unfavorite_page, via: :post

  # TODO: Remove or rewrite endpoint implementation
  # get '/api/v1/taxon_names/' => 'api/v1/taxon_names#all'

  get '/crash_test/' => 'crash_test#index' unless Rails.env.production?

  # Future consideration - move this to an engine, or include multiple draw files and include (you apparenlty
  # lose the autoloading update from the include in this case however)
  scope :api, defaults: { format: :json }, constraints: { id: /\d+/ } do
    scope  '/v1' do

      get '/otus',
        to: 'otus#index'

      get '/asserted_distributions',
        to: 'asserted_distributions#index'

      get '/biological_relationships',
        to: 'biological_relationships#index'

      get '/biological_associations',
        to: 'biological_associations#index'

      get '/observation_matrices/:id/row',
        to: 'observation_matrices#row'

      get '/confidence_levels',
        to: 'confidence_levels#index'

      get '/confidences',
        to: 'confidences#index'

      get '/data_attributes',
        to: 'data_attributes#index'

      get '/taxon_names/:id',
        to: 'taxon_names#show'

      get '/observations/:observation_id/notes',
        to: 'notes#index'

      get '/observations/:observation_id/confidences',
        to: 'confidences#index'

      get '/observations/:observation_id/depictions',
        to: 'depictions#index'

      get '/observations/:observation_id/citations',
        to: 'citations#index'

      get '/observations/:id/annotations',
        to: 'observations#annotations'

      get '/descriptors/:id/annotations',
        to: 'descriptors#annotations'

      get '/descriptors/:id',
        to: 'descriptors#show'

      get '/descriptors/:descriptor_id/notes',
        to: 'notes#index'

      get '/descriptors/:descriptor_id/confidences',
        to: 'confidences#index'

      get '/descriptors/:descriptor_id/observations',
        to: 'observations#index'

      get '/descriptors/:descriptor_id/depictions',
        to: 'depictions#index'

      resources :observations, except: [:new, :edit]

      get '/character_states/:id/annotations',
        to: 'character_states#annotations'

      # TODO: DRY
      # Generate shallow routes for annotations based on model properties, like
      # otu_citations GET /otus/:otu_id/citations(.:format) citations#index
      ApplicationEnumeration.data_models.each do |m|
        ::ANNOTATION_TYPES.each do |t|
          if m.send("has_#{t}?")
            n = m.model_name
            match "/#{n.route_key}/:#{n.param_key}_id/#{t}", to: "#{t}#index",  via: :get, constraints: {format: :json}, defaults: {format: :json}
          end
        end
      end

    end
  end

  scope :api, defaults: { format: :html } do
    scope  '/v1' do
      get '/taxon_names/autocomplete',
        to: 'taxon_names#autocomplete'
    end
  end
end

require_relative 'routes/api'
