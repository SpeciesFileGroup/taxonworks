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
    get 'search' # TODO: deprecate/remove
  end

  member do
    get 'related' # TODO: remove or redirect here to Task route
  end
end

resources :alternate_values, except: [:show, :new] do
  concerns [:data_routes]
end
match '/alternate_values/:global_id/metadata', to: 'alternate_values#metadata', via: :get, defaults: {format: :json}

match '/attributions/licenses', to: 'attributions#licenses', via: :get, defaults: {format: :json}
match '/attributions/role_types', to: 'attributions#role_types', via: :get, defaults: {format: :json}
resources :attributions, except: [:new] do
  concerns [:data_routes]
  collection do
    post :batch_by_filter_scope, defaults: {format: :json}
  end
end

resources :asserted_distributions do
  concerns [:data_routes]
  collection do
    patch :batch_update
    post :batch_template_create, defaults: {format: :json}
    post :preview_simple_batch_load # should be get
    post :create_simple_batch_load, defaults: {format: :json}
    match :filter, to: 'asserted_distributions#index', via: [:get, :post]
  end
  resources :origin_relationships, shallow: true, only: [:index], defaults: {format: :json}
end

resources :biocuration_classifications, only: [:create, :update, :destroy] do
  collection do
    get :index, defaults: {format: :json}
  end
end

resources :biological_associations do
  concerns [:data_routes]
  collection do
    match :filter, to: 'biological_associations#index', via: [:get, :post]

    patch :batch_update
  end
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

resources :cached_maps, only: [:show, :update], defaults: {format: :json} do
end

resources :character_states do
  concerns [:data_routes]
  member do
    get :annotations, defaults: {format: :json}
  end
  collection do
    get :autocomplete, defaults: {format: :json}
  end
end

resources :citation_topics, only: [:create, :update, :destroy]

resources :citations do # except: [:show]
  concerns [:data_routes]
  collection do
    post :batch_create, defaults: {format: :json}
  end
end

get 'confidences/exists', to: 'confidences#exists', defaults: {format: :json}
resources :confidences do # , except: [:edit, :show]
  concerns [:data_routes]
  collection do
    post :confidence_object_update
    post :batch_by_filter_scope, defaults: {format: :json}
  end
end

resources :confidence_levels, only: [:index] do
  collection do
    get 'lookup'
    get 'autocomplete'
    get :select_options, defaults: {format: :json}
  end
end

resources :conveyances do
  concerns [:data_routes]
end

resources :collection_objects do
  concerns [:data_routes]

  resources :biological_associations, shallow: true, only: [:index], defaults: {format: :json}
  resources :taxon_determinations, shallow: true, only: [:index], defaults: {format: :json}

  member do
    scope :inventory do
      get :images, action: :images, defaults: {format: :json}
    end

    get :timeline, defaults: {format: :json}

    # pseudo shallow
    get 'biocuration_classifications', defaults: {format: :json}

    get 'dwc', defaults: {format: :json}
    get 'dwc_compact', defaults: {format: :json}
    get 'dwc_verbose', defaults: {format: :json}
    get 'depictions', constraints: {format: :html}
    get 'containerize'
    get 'dwca', defaults: {format: :json}
    get 'metadata_badge', defaults: {format: :json}
    get :navigation, defaults: {format: :json}
  end

  collection do
    get :index_metadata, defaults: {format: :json}
    match :filter, to: 'collection_objects#index', via: [:get, :post]
    get :dwc_index, defaults: {format: :json}
    get :report, defaults: {format: :json}
    post :preview_castor_batch_load # should be get
    post :create_castor_batch_load # should be get
    post :preview_buffered_batch_load
    post :create_buffered_batch_load
    get :preview_simple_batch_load
    post :create_simple_batch_load
    get :select_options, defaults: {format: :json}
    get :preview, defaults: {format: :json}

    post :batch_update_dwc_occurrence
    patch :batch_update
  end

  resources :origin_relationships, shallow: true, only: [:index], defaults: {format: :json}
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
    post :clone
    get :navigation, defaults: {format: :json}
  end

  collection do
    match :filter, to: 'collecting_events#index', via: [:get, :post]
    get :attributes, defaults: {format: :json}
    get :select_options, defaults: {format: :json}
    get :parse_verbatim_label, defaults: {format: :json}

    post :preview_castor_batch_load
    post :create_castor_batch_load

    post :preview_gpx_batch_load
    post :create_gpx_batch_load

    patch :batch_update
  end
end

resources :combinations, only: [:create, :edit, :update, :destroy, :new, :show] do
  concerns [:data_routes]
  collection do
    get :index, defaults: {format: :json}
  end
end

resources :common_names do
  concerns [:data_routes]
end

match 'containers/for', to: 'containers#for', via: :get, defaults: {format: :json}
resources :containers do # , only: [:create, :update, :destroy] do
  concerns [:data_routes]
  collection do
    get :container_types, defaults: {format: :json}
  end
end

resources :container_items, except: [:edit] do
  concerns [:data_routes]
  collection do
    post :batch_add, defaults: {format: :json}
  end
end

resources :contents do
  concerns [:data_routes]
  collection do
    match :filter, to: 'contents#index', via: [:get, :post]
    get :select_options, defaults: {format: :json}
  end
end

resources :controlled_vocabulary_terms do
  concerns [:data_routes]

  member do
    get 'tagged_objects'
    get 'select', defaults: {format: :json}
  end

  collection do
    post :clone_from_project, default: {format: :json}
  end

end

resources :data_attributes, except: [:show] do
  concerns [:data_routes]

  collection do
    post :batch_update_or_create, defaults: {format: :json}
    post :batch_create, defaults: {format: :json}
    get 'value_autocomplete', defaults: {format: :json}
    get :brief, defaults: {format: :json}
    post :brief, defaults: {format: :json} # for length
    get :import_predicate_autocomplete, defaults: {format: :json}
    match :filter, to: 'data_attributes#index', via: [:get, :post]
  end
end

resources :depictions do
  concerns [:data_routes]
  collection do
    patch :sort
    match :filter, to: 'depictions#index', via: [:get, :post]
  end
end

resources :descriptors do
  concerns [:data_routes]
  member do
    get :annotations, defaults: {format: :json}
  end
  collection do
    match :filter, to: 'descriptors#index', via: [:get, :post]
    get :units
    post :preview_modify_gene_descriptor_batch_load
    post :create_modify_gene_descriptor_batch_load
    post :preview_qualitative_descriptor_batch_load
    post :create_qualitative_descriptor_batch_load
  end
end

resources :downloads, except: [:new, :create] do
  collection do
    get 'list'
  end
  member do
    get 'file'
  end
end

resources :documentation, as: :documentation do
  collection do
    get 'download'
    get 'list'

    patch :sort
  end

  member do
    get 'related'
  end
end

resources :documents do
  concerns [:data_routes]
  collection do
    get :select_options, defaults: {format: :json}
    match :filter, to: 'documents#index', via: [:get, :post]
    get :file_extensions, defaults: {format: :json}
  end
end

# TODO: these should default json?
resources :dwc_occurrences, only: [:create] do
  collection do
    match :filter, to: 'dwc_occurrences#index', via: [:get, :post]
    get :index, defaults: {format: :json}
    get 'metadata', defaults: {format: :json}
    get 'predicates', defaults: {format: :json}
    get 'status', defaults: {format: :json}
    get 'collector_id_metadata', defaults: {format: :json}
    get 'download'
    post 'sweep', as: 'sweep_ghost'
    get :attributes, defaults: {format: :json}
  end
end

resources :extracts do
  concerns [:data_routes]
  collection do
    match :filter, to: 'extracts#index', via: [:get, :post]
    get :autocomplete, defaults: {format: :json}
    get :select_options, defaults: {format: :json}
  end

  resources :origin_relationships, shallow: true, only: [:index], defaults: {format: :json}
end

resources :field_occurrences do
  concerns [:data_routes]

  resources :taxon_determinations, shallow: true, only: [:index], defaults: {format: :json}

  collection do
    match :filter, to: 'field_occurrences#index', via: [:get, :post]
    get :select_options, defaults: {format: :json}
  end
end

resources :gazetteer_imports, only: [:destroy], defaults: { format: :json } do
  collection do
    get :all, defaults: {format: :json}
  end
end

resources :gazetteers do
  concerns [:data_routes]
  collection do
    post :import, defaults: {format: :json}
    post :preview, defaults: {format: :json} # post to support long WKT strings
    get :shapefile_fields, default: {format: :json}
    get :shapefile_text_field_values, default: {format: :json}
    get :select_options, defaults: {format: :json}
  end
end

resources :geographic_areas, only: [:index, :show] do
  collection do
    get 'download'
    get 'list'
    get 'autocomplete'
    get 'search'

    post 'display_coordinates' # TODO should not be POST
    get 'display_coordinates', as: 'getdisplaycoordinates'
    get :select_options, defaults: {format: :json}
    get :by_lat_long, defaults: {format: :json}
  end

  member do
    get 'related'
  end
end

resources :gene_attributes do
  concerns [:data_routes]
end

resources :geographic_areas_geographic_items, except: [:index, :show]

resources :geographic_area_types

resources :geographic_items

resources :georeferences, only: [:index, :destroy, :new, :create, :show, :edit, :update] do
  concerns [:data_routes]
end

# TODO: fix broken interfaces, deprecate?
namespace :georeferences do
  resources :geo_locates, only: [:new, :create]
end

resources :identifiers, except: [:show] do
  concerns [:data_routes]

  # Must be before member
  collection do
    patch :reorder, defaults: {format: :json}
    get :identifier_types, {format: :json}
    post :namespaces, {format: :json}
    post :batch_by_filter_scope, defaults: {format: :json}
  end

  member do
    get :show, defaults: {format: :json}
  end
end

resources :images do
  concerns [:data_routes]
  member do
    get 'extract(/:x/:y/:width/:height)', action: :extract
    get 'scale(/:x/:y/:width/:height/:new_width/:new_height)', action: :scale
    get 'scale_to_box(/:x/:y/:width/:height/:box_width/:box_height)', action: :scale_to_box
    get 'ocr(/:x/:y/:width/:height)', action: :ocr
    patch 'rotate', action: 'rotate'
    patch 'regenerate_derivative', action: 'regenerate_derivative'
  end
  collection do
    match :filter, to: 'images#index', via: [:get, :post]
    get :select_options, defaults: {format: :json}
  end
end

resources :import_datasets do
  concerns [:data_routes]
  member do
    post 'import'
    post 'stop_import'
  end
  resources :dataset_records, only: [:index, :create, :show, :update, :destroy] do
    collection do
      get 'autocomplete_data_fields'
      patch 'set_field_value'
    end
  end
end

resources :keywords, only: [] do
  collection do
    get :select_options, defaults: {format: :json}
  end
end

resources :labels do
  collection do
    get :list
    scope :factory do
      post :unit_tray_header1, controller: 'labels/factory', defaults: {format: :json}
    end
  end
  # is data?
end

resources :languages, only: [:show] do
  collection do
    get 'autocomplete'
    get :select_options, defaults: {format: :json}
  end
end

resources :leads do
  concerns [:data_routes]
  member do
    post :add_children, defaults: {format: :json}
    post :insert_couplet, defaults: {format: :json}
    post :destroy_children, defaults: {format: :json}
    post :delete_children, defaults: {format: :json}
    post :duplicate
    get :redirect_option_texts, defaults: {format: :json}
    get :otus, defaults: {format: :json}
    post :destroy_subtree, defaults: {format: :json}
    patch :reorder_children, defaults: {format: :json}
    post :insert_key, defaults: {format: :json}
  end
end

resources :loans do
  concerns [:data_routes]
  member do
    get :recipient_form
  end

  collection do
    get :attributes, defaults: {format: :json}
    match :filter, to: 'loans#index', via: [:get, :post]
    get :select_options, defaults: {format: :json}
  end
end

resources :loan_items do
  concerns [:data_routes]

  collection do
    post :batch_create
    post :batch_return
    post :batch_move
  end
end

resources :namespaces do
  collection do
    get :autocomplete, defaults: {format: :json} # TODO: add JSON to all autocomplete as default, until then this line has to be above concerns
    post :preview_simple_batch_load
    post :create_simple_batch_load
    get :select_options, defaults: {format: :json}
  end

  concerns [:data_routes]
end

match 'observation_matrices/row/', to: 'observation_matrices#row', via: :get, method: :json
match 'observation_matrices/column/', to: 'observation_matrices#column', via: :get, method: :json
resources :observation_matrices do
  concerns [:data_routes]

  resources :observation_matrix_columns, shallow: true, only: [:index], defaults: {format: :json}
  resources :observation_matrix_rows, shallow: true, only: [:index], defaults: {format: :json}
  resources :observation_matrix_row_items, shallow: true, only: [:index], defaults: {format: :json}
  resources :observation_matrix_column_items, shallow: true, only: [:index], defaults: {format: :json}

  member do
    scope :export do
      get :nexml, defaults: {format: :rdf}
      get :tnt
      get :nexus
      get :otu_content
      get :csv
      get :descriptor_list
      #  get :biom
    end

    get :reorder_rows, defaults: {format: :json}
    get :reorder_columns, defaults: {format: :json}

    get :row_labels, defaults: {format: :json}
    get :column_labels, defaults: {format: :json}
  end

  collection do
    get :otus_used_in_matrices, {format: :json}
    get :nexus_data, {format: :json}

    post :batch_create, {format: :json}
    post :batch_add, {format: :json}
    post :import_from_nexus, {format: :json}
  end
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

resources :observation_matrix_column_items, except: [:new] do
  concerns [:data_routes]
  collection do
    post :batch_create
  end
end

resources :observation_matrix_row_items, except: [:new] do
  concerns [:data_routes]
  collection do
    post :batch_create
  end
end

resources :observations do
  concerns [:data_routes]
  collection do
    match :filter, to: 'observations#index', via: [:get, :post]
    delete :destroy_row, defaults: {format: :json}
    delete :destroy_column, defaults: {format: :json}
    post :code_column, defaults: {format: :json}
  end

  member do
    get :annotations, defaults: {format: :json}
  end
end

resources :notes, except: [:show] do
  concerns [:data_routes]
end



resources :otus do
  concerns [:data_routes]
  resources :biological_associations, shallow: true, only: [:index], defaults: {format: :json}
  resources :asserted_distributions, shallow: true, only: [:index], defaults: {format: :json}
  resources :common_names, shallow: true, only: [:index], defaults: {format: :json}
  resources :taxon_determinations, shallow: true, only: [:index], defaults: {format: :json}

  resources :contents, only: [:index]

  collection do
    match :filter, to: 'otus#index', via: [:get, :post]
    # TODO: this is get
    post :preview_data_attributes_batch_load
    post :create_data_attributes_batch_load

    # TODO: this is get
    post :preview_simple_batch_load # should be get (batch loader fix)
    post :create_simple_batch_load

    # TODO: this is get
    post :preview_simple_batch_file_load
    post :create_simple_batch_file_load

    # TODO: this is get
    post :preview_identifiers_batch_load
    post :create_identifiers_batch_load

    get :select_options, defaults: {format: :json}

    patch :batch_update
  end

  member do
    get :timeline, defaults: {format: :json}
    get :navigation, defaults: {format: :json}
    get :breadcrumbs, defaults: {format: :json}
    get :coordinate, defaults: {format: :json}

    get 'inventory/distribution', action: :distribution, defaults: {format: :json}
    get 'inventory/taxonomy', action: :api_taxonomy_inventory, as: :taxonomy_inventory
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

resources :otu_relationships do
  collection do
    get :list
  end
  concerns [:data_routes]
end

resources :organizations do
  collection do
    get :autocomplete, defaults: {format: :json}
    get :select_options, defaults: {format: :json}
  end
  concerns [:data_routes]
end

resources :origin_relationships do
  concerns [:data_routes]
end

resources :otu_page_layout_sections, only: [:create, :update, :destroy]

match 'people/role_types', to: 'people#role_types', via: :get, method: :json
resources :people do
  concerns [:data_routes]

  collection do
    get :select_options, defaults: {format: :json}
    match :filter, to: 'people#index', via: [:get, :post]
  end

  member do
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
    post :batch_sync_to_project, defaults: {format: :json}
  end
end

resources :protocols do
  concerns [:data_routes]
  collection do
    get :select_options, defaults: {format: :json}
  end
end

resources :protocol_relationships do
  concerns [:data_routes]
  collection do
    post :batch_by_filter_scope, defaults: {format: :json}
  end
end

get 'public_contents/exists', to: 'public_contents#exists', defaults: {format: :json}
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

resources :roles, only: [:index, :create, :update, :destroy], defaults: {format: :json}

resources :serials do
  concerns [:data_routes]
  collection do
    get :select_options, defaults: {format: :json}
  end
end

resources :serial_chronologies, only: [:create, :update, :destroy]

resources :sequences do
  concerns [:data_routes]

  collection do
    get :select_options, defaults: {format: :json}

    post :preview_genbank_batch_file_load
    post :create_genbank_batch_file_load

    post :preview_genbank_batch_load
    post :create_genbank_batch_load

    post :preview_primers_batch_load
    post :create_primers_batch_load
  end

  resources :origin_relationships, shallow: true, only: [:index], defaults: {format: :json}
end

resources :sequence_relationships do
  concerns [:data_routes]

  collection do
    post :preview_primers_batch_load
    post :create_primers_batch_load
  end
end

resources :sled_images, only: [:update, :create, :destroy, :show], defaults: {format: :json} do
  collection do
    get :index, defaults: {format: :json}
  end
end

resources :sounds do
  concerns [:data_routes]
  collection do
    match :filter, to: 'sounds#index', via: [:get, :post]
    get :select_options, defaults: {format: :json}
  end
end

resources :sources do
  concerns [:data_routes]
  collection do
    match :filter, to: 'sources#index', via: [:get, :post]
    get :attributes, defaults: {format: :json}
    get :select_options, defaults: {format: :json}
    post :preview_bibtex_batch_load # should be get
    post :create_bibtex_batch_load
    get :parse, defaults: {format: :json}
    get :citation_object_types, defaults: {format: :json}
    get :csl_types, defaults: {format: :json}
    get :generate, defaults: {format: :json}
    patch :batch_update
    get :download_formatted, defaults: {format: :json}
  end

  member do
    post :clone
  end

  resources :origin_relationships, shallow: true, only: [:index], defaults: {format: :json}
end

resources :sqed_depictions, only: [:update] do
  collection do
    get :metadata_options, defaults: {format: :json}
  end
end

get 'tags/exists', to: 'tags#exists', defaults: {format: :json}
resources :tags, except: [:edit, :show, :new] do
  concerns [:data_routes]
  collection do
    get :autocomplete
    post :tag_object_update
    post :batch_create, defaults: {format: :json}
    post :batch_remove, defaults: {format: :json}
  end
end

resources :tagged_section_keywords, only: [:create, :update, :destroy]

resources :taxon_determinations do
  collection do
    post :batch_create, defaults: {format: :json}
    patch :reorder, defaults: {format: :json}
  end
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
    match :filter, to: 'taxon_names#index', via: [:get, :post]

    post :preview_simple_batch_load # should be get
    post :create_simple_batch_load
    get :ranks, {format: :json}

    post :preview_nomen_batch_load
    post :create_nomen_batch_load

    get :parse, defaults: {format: :json}
    get :random

    get :rank_table, defaults: {format: :json}
    get :predicted_rank, {format: :json}

    patch :batch_update

    get :origin_citation, defaults: {format: :json}
    post :origin_citation, defaults:  {format: :json}
  end

  member do
    get :original_combination, defaults: {format: :json}
  end
end

resources :taxon_name_classifications do
  concerns [:data_routes]
  collection do
    get :taxon_name_classification_types
  end
  member do
    get :show
  end
end

resources :taxon_name_relationships do
  concerns [:data_routes]
  collection do
    get :type_relationships, {format: :json}
    get :taxon_name_relationship_types, {format: :json}
    match :filter, to: 'taxon_name_relationships#index', via: [:get, :post]
  end
end

resources :topics, only: [:create] do
  collection do
    get :index, defaults: { format: :json }
    get :select_options, defaults: {format: :json}
    get 'get_definition/:id', action: 'get_definition'
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
