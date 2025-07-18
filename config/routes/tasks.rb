scope :tasks do
  scope :taxon_name_relationships do
    scope :filter, controller: 'tasks/taxon_name_relationships/filter' do
      get '/', action: :index, as: 'filter_taxon_name_relationships_task'
    end
  end

  scope :gazetteers do
    scope :import_gazetteers, controller: 'tasks/gazetteers/import_gazetteers' do
      get '/', action: :index, as: 'import_gazetteers_task'
    end

    scope :new_gazetteer, controller: 'tasks/gazetteers/new_gazetteer' do
      get '/', action: :index, as: 'new_gazetteer_task'
    end
  end

  scope :sounds do
    scope :filter, controller: 'tasks/sounds/filter' do
      get '/', action: :index, as: 'filter_sounds_task'
    end

    scope :browse, controller: 'tasks/sounds/browse' do
      get '/', action: :index, as: 'browse_sounds_task'
    end
  end

  scope :controlled_vocabulary_terms do
    scope :projects_summary, controller: 'tasks/controlled_vocabulary_terms/projects_summary' do
      get '/', action: :index, as: 'summarize_projects_controlled_vocabulary_terms_task'
    end
  end

  scope :containers do
    scope :new_container, controller: 'tasks/containers/new_container' do
      get '/', action: :index, as: 'new_container_task'
    end
  end

  scope :dwc_occurrences do
    scope :filter, controller: 'tasks/dwc_occurrences/filter' do
      get '/', action: :index, as: 'filter_dwc_occurrences_task'
    end

    scope :status, controller: 'tasks/dwc_occurrences/status' do
      get '/', action: :index
      post '/', action: :index
    end
  end

  scope :data_attributes do
    scope :multi_update, controller: 'tasks/data_attributes/multi_update' do
      get '/', action: :index, as: 'index_multi_update_task'
    end

    scope :field_synchronize, controller: 'tasks/data_attributes/field_synchronize' do
      get '/', action: :index, as: 'field_synchronize_task'
      #get :values, defaults: {format: :json}
      match :values, action: :values,  defaults: {format: :json}, via: [:get, :post]
    end
  end

  scope :leads do
    scope :hub, controller: 'tasks/leads/hub' do
      get '/', action: :index, as: 'leads_hub_task'
    end

    scope :show, controller: 'tasks/leads/show' do
      get '/', action: :index, as: 'show_lead_task'
    end

    scope :new_lead, controller: 'tasks/leads/new_lead' do
      get '/', action: :index, as: 'new_lead_task'
    end

    scope :print, controller: 'tasks/leads/print' do
      get '/', action: :index, as: 'print_key_task'
      get :table, action: :table, as: 'print_key_table_task'
    end
  end

  scope :metadata do
    scope :vocabulary do
      scope :project_vocabulary, controller: 'tasks/metadata/vocabulary/project_vocabulary' do
        get '/', action: :index, as: 'project_vocabulary_task'
        get :data_models, defaults: {format: :json}
      end
    end
  end

  scope :cached_maps do
    scope :report, controller: 'tasks/cached_maps/report' do
      get :items_by_otu, as: 'cached_map_items_by_otus_task'
    end
  end

  scope :geographic_items do
    scope :debug, controller: 'tasks/geographic_items/debug' do
      get '/', action: :index, as: 'debug_geographic_item_task'
    end
  end

  scope :geographic_areas do
    scope :usage, controller: 'tasks/geographic_areas/usage' do
      get '/', action: :index, as: 'geographic_area_usage_task'
    end
  end

  scope :observations do
    scope :filter, controller: 'tasks/observations/filter' do
      get '/', as: 'filter_observations_task', action: :index
    end
  end

  scope :shared do
    scope :related_data, controller: 'tasks/shared/related_data' do
      get '/', action: :index, as: 'related_data_task'
    end
  end

  scope :administrator do
    scope :project_classification, controller: 'tasks/administrator/project_classification' do
      get '/', as: 'project_classification_task', action: :index
    end

    scope :batch_add_users, controller: 'tasks/administrator/batch_add_users' do
      get '/', as: 'batch_add_users_task', action: :index
    end
  end

  scope :dwca_import, controller: 'tasks/dwca_import/dwca_import' do
    get :index, as: 'dwca_import_task'
    post 'upload'
    post 'update_catalog_number_namespace'
    post 'update_catalog_number_collection_code_namespace'
    post 'set_import_settings'
  end

  scope :field_occurrences do
    scope :filter, controller: 'tasks/field_occurrences/filter' do
      get '/', as: 'filter_field_occurrences_task', action: :index
    end

    scope :browse, controller: 'tasks/field_occurrences/browse' do
      get '/', as: 'browse_field_occurrence_task', action: :index
    end

    scope :new_field_occurrences, controller: 'tasks/field_occurrences/new_field_occurrences' do
      get '/', as: 'new_field_occurrence_task', action: :index
    end
  end

  scope :namespaces do
    scope :new_namespace, controller: 'tasks/namespaces/new_namespace' do
      get '/', action: :index, as: 'new_namespace_task'
    end
  end

  scope :extracts do
    scope :filter, controller: 'tasks/extracts/filter' do
      get '/', as: 'filter_extract_task', action: :index
    end

    scope :new_extract, controller: 'tasks/extracts/new_extract' do
      get '/', action: :index, as: 'new_extract_task'
    end
  end

  scope :asserted_distributions do
    scope :filter, controller: 'tasks/asserted_distributions/filter' do
      get '/', as: 'filter_asserted_distributions_task', action: :index
    end

    scope :basic_endemism, controller: 'tasks/asserted_distributions/basic_endemism' do
      get '/', action: :index, as: 'asserted_distributions_basic_endemism_task'
    end

    scope :new_asserted_distribution, controller: 'tasks/asserted_distributions/new_asserted_distribution' do
      get '/', action: :index, as: 'new_asserted_distribution_task'
    end
  end

  scope :dwc do
    scope :dashboard, controller: 'tasks/dwc/dashboard' do
      get '/', action: :index, as: 'dwc_dashboard_task'
      get :index_versions, defaults: {format: :json}
      get :taxonworks_extension_methods, defaults: {format: :json}

      post 'generate_download', as: 'generate_dwc_download_task', defaults: {format: :json}
      post :create_index, as: 'create_dwc_index_task', defaults: {format: :json}
    end
  end

  scope :exports do
    scope :coldp, controller: 'tasks/exports/coldp' do
      get '/', action: :index, as: 'export_coldp_task'
      get 'download', as: 'download_coldp_task'
    end

    scope :nomenclature, controller: 'tasks/exports/nomenclature' do
      get 'basic', action: :basic, as: 'export_basic_nomenclature_task'
      get 'download_basic', as: 'download_basic_nomenclature_task'
    end
  end

  scope :browse_annotations, controller: 'tasks/object_annotations/browse_annotations' do
    get '/', action: :index, as: 'browse_annotations_task'
  end

  scope :citations do
    scope :otus, controller: 'tasks/citations/otus' do
      get '', as: 'cite_otus_task', action: :index
    end
  end

  scope :confidences do
    scope :visualize, controller: 'tasks/confidences/visualize' do
      get 'index', as: 'visualize_confidences_task'
    end
  end

  scope :content do
    scope :filter, controller: 'tasks/contents/filter' do
      get '/', action: :index, as: 'filter_contents_task'
    end
    scope :publisher, controller: 'tasks/content/publisher' do
      get 'summary', as: :publisher_summary,  defaults: {format: :json}
      get 'topic_table', as: :publisher_topic_table, defaults: {format: :json}
      get '/', action: :index, as: 'publisher_task'
      post 'publish_all', defaults: {format: :json}
      post 'unpublish_all', defaults: {format: :json}
    end

    scope :by_nomenclature, controller: 'tasks/content/by_nomenclature' do
      get '/', action: :index, as: 'content_by_nomenclature_task'
    end

    scope :editor, controller: 'tasks/content/editor' do
      get '/', action: :index, as: 'content_editor_task'
      get 'recent_topics', as: 'content_editor_recent_topics_task'
      get 'recent_otus', as: 'content_editor_recent_otus_task'
    end
  end

  scope :descriptors do
    scope :filter, controller: 'tasks/descriptors/filter' do
      get '/', action: :index, as: 'filter_descriptors_task'
    end

    scope :new_descriptor, controller: 'tasks/descriptors/new_descriptor' do
      get '(:descriptor_id)', action: :index, as: 'new_descriptor_task'
    end
  end

  scope :images do
    scope :new_filename_depicting_image, controller: 'tasks/images/new_filename_depicting_image' do
      get '/', action: :index, as: 'new_filename_depicting_image_task'
    end

    scope :filter, controller: 'tasks/images/filter' do
      get '/', action: :index, as: 'filter_images_task'
    end

    scope :new_image, controller: 'tasks/images/new_image' do
      get :index, as: 'new_image_task'
    end
  end

  scope :labels do
    scope :print_labels, controller: 'tasks/labels/print_labels' do
      get '/',  as: 'print_labels_task', action: :index
    end
  end

  scope :loans do
    scope :dashboard, controller: 'tasks/loans/dashboard' do
      get '/', action: :index, as: 'loan_dashboard_task'
    end

    scope :filter, controller: 'tasks/loans/filter' do
      get '/', action: :index, as: 'filter_loans_task'
    end

    scope :edit_loan, controller: 'tasks/loans/edit_loan' do
      get 'loan_item_metadata', as: 'loan_item_metdata', defaults: {format: :json}
      get '(:id)', action: :index, as: 'edit_loan_task'
    end
  end

  scope :projects do
    scope :week_in_review, controller: 'tasks/projects/week_in_review' do
      get '/', action: :index, as: 'week_in_review_task'
      get :data, as: 'week_in_review_data', defaults: {format: :json}
    end

    scope :activity, controller: 'tasks/projects/activity' do
      get :index, as: :project_activity_task
      get :type_report, as: :project_activity_type_report
    end

    scope :preferences, controller: 'tasks/projects/preferences' do
      get :index, as: 'project_preferences_task'
    end

#   scope :taxonworks_project, controller: 'tasks/exports/taxonworks_project' do
#     get '/', action: :index, as: 'export_taxonworks_project_task'
#     get 'download', as: 'download_taxonworks_project_task'
#   end

    # Downloads here
    scope :data, controller: 'tasks/projects/data' do
      get '/', action: :index, as: 'project_data_task'

      get 'tsv_download', as: 'generate_tsv_download_task'
      get 'sql_download', as: 'generate_sql_download_task'

    end
  end

  scope :sources do
    scope :source_citation_totals, controller: 'tasks/sources/source_citation_totals' do
      get '/', action: :index, as: 'source_citation_totals_task'
    end

    scope :gnfinder, controller: 'tasks/sources/gnfinder' do
      get '/', action: :index, as: 'gnfinder_task'
    end

    scope :filter, controller: 'tasks/sources/filter' do
      get '/', action: :index, as: 'filter_sources_task'
    end

    scope :new_source, controller: 'tasks/sources/new_source' do
      get '/', action: :index, as: 'new_source_task'
      get 'crossref_preview', as: 'preview_source_from_crossref_task', defaults: {format: :json}
    end

    scope :hub, controller: 'tasks/sources/hub' do
      get '/', action: :index, as: 'source_hub_task'
    end

    scope :individual_bibtex_source, controller: 'tasks/sources/individual_bibtex_source' do
      get '/', action: :index, as: 'new_bibtex_source_task'
    end
  end

  scope :collecting_events do
    scope :metadata, controller: 'tasks/collecting_events/metadata' do
      match '/', action: :index, via: [:get, :post], as: :collecting_event_metadata_task
    end

    scope :spatial_summary, controller: 'tasks/collecting_events/spatial_summary' do
      match '/', action: :index, via: [:get, :post], as: 'collecting_events_spatial_summary_task'
    end

    scope :new_collecting_event, controller: 'tasks/collecting_events/new_collecting_event' do
      get '/', action: :index, as: 'new_collecting_event_task'
    end

    scope :browse, controller: 'tasks/collecting_events/browse' do
      get '/', action: :index, as: 'browse_collecting_events_task'
    end

    scope :filter, controller: 'tasks/collecting_events/filter' do
      match '/', action: :index, via: [:get, :post], as: 'filter_collecting_events_task'
    end

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

    scope :stepwise do
      scope :collectors, controller: 'tasks/collecting_events/stepwise/collectors' do
        get '/', action: :index, as: 'stepwise_collectors_task'
        get :data, defaults: {format: :json}
      end
    end
  end

  scope :collection_objects do
    scope :freeform_digitize, controller: 'tasks/collection_objects/freeform_digitize' do
      get '/', action: :index, as: 'freeform_digitize_task'
    end

    scope :outdated_names, controller: 'tasks/collection_objects/outdated_names' do
      get '/', action: :index, as: 'collection_object_outdated_names_task'
    end

    scope :table, controller: 'tasks/collection_objects/table' do
      get '/', action: :index, as: 'collection_object_table_task'
    end

    scope :chronology, controller: 'tasks/collection_objects/chronology' do
      get '/', action: :index, as: 'collection_object_chronology_task'
    end

    scope :stepwise do
      scope :determinations, controller: 'tasks/collection_objects/stepwise/determinations' do
        get '/', action: :index, as: 'stepwise_determinations_task'
        get :data, defaults: {format: :json}
      end
    end

    scope :classification_summary, controller: 'tasks/collection_objects/classification_summary' do
      get '/', action: :index, as: 'classification_summary_task'
      get :report, as: 'classification_summary_report',  defaults: {format: :js}
    end

    scope :match, controller: 'tasks/collection_objects/match' do
      get '/', action: :index, as: 'match_collection_objects_task'
    end

    scope :grid_digitize, controller: 'tasks/collection_objects/grid_digitize' do
      get '/', action: :index, as: 'grid_digitize_task'
    end

    scope :summary, controller: 'tasks/collection_objects/summary' do
      get '/', action: :index, as: 'collection_object_summary_task'
      get :report, as: 'collection_object_summary_report',  defaults: {format: :js}
    end

    scope :filter, controller: 'tasks/collection_objects/filter' do
      get '/', as: 'filter_collection_objects_task', action: :index
    end

    scope :browse, controller: 'tasks/collection_objects/browse' do
      get '/', as: 'browse_collection_objects_task', action: :index
    end
  end

  scope :accessions do
    scope :comprehensive, controller: 'tasks/accessions/comprehensive' do
      get '/', action: :index, as: 'comprehensive_collection_object_task'
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
      # needs a name to remove conflicts?
      get 'collecting_events', format: :js
    end
  end

  scope :biological_associations do
    scope :new_biological_association, controller: 'tasks/biological_associations/new_biological_association' do
      get '/', action: :index, as: 'new_biological_association_task'
    end

    scope :biological_associations_graph, controller: 'tasks/biological_associations/biological_associations_graph' do
      get '/', action: :index, as: 'edit_biological_associations_graph_task'
    end

    scope :filter, controller: 'tasks/biological_associations/filter' do
      get '/', action: :index, as: 'filter_biological_associations_task'
    end

    scope :dot, controller: 'tasks/biological_associations/dot' do
      get 'by_project/:project_id', action: :project_dot_graph, as: :biological_associations_dot_graph_task
    end

    scope :dwc_extension_preview, controller: 'tasks/biological_associations/dwc_extension_preview' do
      get '/', action: :index, as: 'biological_associations_dwc_extension_preview_task'
      post '/', action: :index
    end

    scope :simple_table, controller: 'tasks/biological_associations/simple_table' do
      get '/', action: :index, as: 'biological_associations_simple_table_task'
      post '/', action: :index
    end

    scope :globi_preview, controller: 'tasks/biological_associations/globi_preview' do
      get '/', action: :index, as: 'biological_associations_globi_preview_task'
      post '/', action: :index
    end

    scope :family_summary, controller: 'tasks/biological_associations/family_summary' do
      get '/', action: :index, as: 'biological_associations_family_summary_task'
      post '/', action: :index
    end

    scope :graph, controller: 'tasks/biological_associations/graph' do
      get '/', action: :index, as: 'biological_associations_graph_task'
      post 'data', action: :data, defaults: {format: :json}
      get  :data, defaults: {format: :json}
    end

    scope :summary, controller: 'tasks/biological_associations/summary' do
      get '/', action: :index, as: 'biological_associations_summary_task'
      post 'data', action: :data, defaults: {format: :json}
      get  :data, defaults: {format: :json}
    end

  end

  scope :biological_relationships do
    scope :composer, controller: 'tasks/biological_relationships/composer' do
      get '/', action: :index, as: 'biological_relationship_composer_task'
    end
  end

  scope :contents, controller: 'tasks/content/preview' do
    get 'otu_content_for_layout/:otu_id', action: :otu_content_for_layout, as: 'preview_otu_content_for_layout'
    get ':otu_id', action: 'otu_content', as: 'preview_otu_content'
  end

  scope :controlled_vocabularies do
    scope :manage, controller: 'tasks/controlled_vocabularies/manage' do
      get '/', action: :index, as: 'manage_controlled_vocabulary_terms_task'
    end

    scope :topics_hub, controller: 'tasks/controlled_vocabularies/topics_hub' do
      get 'index', as: 'index_topics_hub_task'
    end

    scope :biocuration, controller: 'tasks/controlled_vocabularies/biocuration' do
      get 'build_collection', as: 'build_biocuration_groups_task'
      post 'build_biocuration_group', as: 'build_biocuration_group_task'

      post 'create_biocuration_group'
      post 'create_biocuration_class'
    end
  end

  scope :gis do
    scope :simplemappr, controller: 'tasks/gis/simplemappr' do
      match '/', action: :index, via: [:get, :post]
    end

    scope :geographic_area_lookup, controller: 'tasks/gis/geographic_area_lookup' do
      get 'index', as: 'geographic_area_lookup_task'
      get 'resolve', as: 'geographic_area_lookup_resolve_task', format: :js
    end
  end

  scope :gis, controller: 'tasks/gis/draw_map_item' do
    get 'new_map_item', action: 'new', as: 'new_draw_map_item_task'
    post 'create_map_item', action: 'create', as: 'create_draw_map_item_task'
    get 'collect_item', as: 'collect_draw_item_task'
  end

  scope :gis, controller: 'tasks/gis/otu_distribution_data' do
    get 'otu_distribution_data', action: 'show', as: 'otu_distribution_data_task'
  end

  scope :nomenclature do
    scope :paper_catalog, controller: 'tasks/nomenclature/paper_catalog' do
      get '/', action: :index, as: 'paper_catalog_generator_task'
      get :preview, as: 'paper_catalog_preview_task'
    end

    scope :match, controller: 'tasks/nomenclature/match' do
      get :index, as: 'match_nomenclature_task'
    end

    scope :stats, controller: 'tasks/nomenclature/stats' do
      get '', action: :index, as: 'nomenclature_stats_task'
    end

    scope :new_combination, controller: 'tasks/nomenclature/new_combination' do
      get '', action: :index, as: 'new_combination_task'
    end

    scope :new_taxon_name, controller: 'tasks/nomenclature/new_taxon_name' do
      get '', action: :index, as: 'new_taxon_name_task'
    end

    scope :browse, controller: 'tasks/nomenclature/browse' do
      get '', action: :index, as: 'browse_nomenclature_task'
    end

    scope :by_source, controller: 'tasks/nomenclature/by_source' do
      get '', action: :index, as: 'nomenclature_by_source_task'
    end
  end

  scope :observation_matrices do
    scope :import_nexus, controller: 'tasks/observation_matrices/import_nexus' do
      get '/', action: :index, as: 'import_nexus_task'
    end

    scope :matrix_column_coder, controller: 'tasks/observation_matrices/matrix_column_coder' do
      get :index, as: 'index_matrix_column_coder_task'
    end

    scope :dashboard, controller: 'tasks/observation_matrices/dashboard' do
      get '', as: 'observation_matrices_dashboard_task', action: :index
    end

    scope :view, controller: 'tasks/observation_matrices/view' do
      get '(:observation_matrix_id)', as: 'observation_matrix_view_task', action: :index
    end

    scope :observation_matrix_hub, controller: 'tasks/observation_matrices/observation_matrix_hub' do
      get '', as: 'observation_matrices_hub_task', action: :index
      post 'copy_observations', as: 'observation_matrix_hub_copy_observations', defaults: {format: :json}
    end

    scope :new_matrix, controller: 'tasks/observation_matrices/new_matrix' do
      get 'observation_matrix_row_item_metadata', as: 'observation_matrix_row_item_metadata', defaults: {format: :json}
      get 'observation_matrix_column_item_metadata', as: 'observation_matrix_column_item_metdata', defaults: {format: :json}
      get '(:observation_matrix_id)', action: :index, as: 'new_matrix_task'
    end

    scope :row_coder, controller: 'tasks/observation_matrices/row_coder' do
      get 'index', as: 'index_row_coder_task'
      get 'set', as: 'set_row_coder_task'
    end

    scope :description_from_observation_matrix, controller: 'tasks/observation_matrices/description_from_observation_matrix' do
      get 'description', action: :description, defaults: {format: :json}
    end

    scope :interactive_key, controller: 'tasks/observation_matrices/interactive_key' do
      get ':observation_matrix_id/key', action: :key, defaults: {format: :json}
      get '/', action: :index, as: 'interactive_key_task'
    end

    scope :image_matrix, controller: 'tasks/observation_matrices/image_matrix' do
      get ':observation_matrix_id/key', action: :key, defaults: {format: :json}
      get '/', action: :index, as: 'image_matrix_task'
    end
  end

  scope :otus do
    scope :duplicates, controller: 'tasks/otus/duplicates' do
      get '/', action: 'index', as: 'duplicate_otus_task'
     get :data, as: 'duplicate_otus_task_data', defaults: {format: :json}
    end

    scope :new_otu, controller: 'tasks/otus/new_otu' do
      get '/', action: :index, as: 'new_otu_task'
    end

    scope :browse_asserted_distributions, controller: 'tasks/otus/browse_asserted_distributions' do
      get '/', action: :index, as: 'browse_asserted_distributions_task'
    end

    scope :browse, controller: 'tasks/otus/browse' do
      get '/(:otu_id)', action: :index, as: 'browse_otus_task'
    end

    scope :filter, controller: 'tasks/otus/filter' do
      get '/', action: :index, as: 'filter_otus_task'

      # TODO: remove all
      #   get 'find', as: 'find_otus_task' # 'find_area_and_date_task'
      #   get 'set_area', as: 'set_area_for_otu_filter'
      #   get 'set_author', as: 'set_author_for_otu_filter'
      #   get 'set_nomen', as: 'set_nomen_for_otu_filter'
      #   get 'set_verbatim', as: 'set_verbatim_for_otu_filter'
      post 'download', action: 'download', as: 'download_otus_filter_result' # nested/large URIs
    end

  end

  scope :people do
    scope :author, controller: 'tasks/people/author' do
      get '/', action: :index, as: 'author_list_task'
      get 'source_list_for_author/:id', action: 'source_list_for_author', as: 'author_source_list_task'
    end

    scope :filter, controller: 'tasks/people/filter' do
      get '/', action: :index, as: :filter_people_task
    end

    scope :summary, controller: 'tasks/people/summary' do
      get '/', action: :index, as: 'people_summary_task'
      post 'data', action: :data, defaults: {format: :json}
      get  :data, defaults: {format: :json}
    end
  end

  scope :unify do
    scope :objects, controller: 'tasks/unify/objects' do
      get '/', action: :index, as: 'unify_objects_task'
    end

    scope :people, controller: 'tasks/unify/people' do
      get '/', action: :index, as: 'unify_people_task'
    end
  end

  scope :serials, controller: 'tasks/serials/similar' do
    get 'like(/:id)', action: 'like', as: 'similar_serials_task'
  end

  scope :taxon_names do
    scope :gender, controller: 'tasks/taxon_names/gender' do
      match '/', action: :index, via: [:get, :post], as: 'taxon_name_gender_task'
    end

    scope :stats, controller: 'tasks/taxon_names/stats' do
      get '/', action: :index,  as: 'taxon_name_stats_task'
      post '/', action: :index,  as: 'post_taxon_name_stats_task'
    end

    scope :merge, controller: 'tasks/taxon_names/merge' do
      get '/', action: :index, as: 'taxon_name_merge_task'
      get 'report', as: 'taxon_name_merge_report'
      post 'merge', as: 'taxon_name_merge'
    end

    scope :synchronize_otus, controller: 'tasks/taxon_names/synchronize_otus' do
      get 'index', as: 'synchronize_otus_to_nomenclature_task'
      post 'index', as: 'preview_synchronize_otus_to_nomenclature_task'
      post 'synchronize', as: 'synchronize_otus_task'
    end

    scope :filter, controller: 'tasks/taxon_names/filter' do
      get '/', as: 'filter_taxon_names_task', action: :index
    end

    scope :table, controller: 'tasks/taxon_names/table' do
      match '/', action: :index, via: [:get, :post], as: :taxon_names_table_task
    end
  end

  scope :type_material do
    scope :edit_type_material, controller: 'tasks/type_material/edit_type_material' do
      get '/', as: 'edit_type_material_task', action: :index
    end
  end

  scope :usage, controller: 'tasks/usage/user_activity' do
    get ':id', action: 'report', as: 'user_activity_report_task'
  end

  scope :graph do
    scope :object, controller: 'tasks/graph/object_graph' do
      get '/', action: :index, as: 'object_graph_task'
    end
  end

end
