scope :tasks do
  scope :asserted_distributions do
    scope :basic_endemism, controller: 'tasks/asserted_distributions/basic_endemism' do
      get '/', action: :index, as: 'asserted_distributions_basic_endemism_task'
    end

    scope :new_asserted_distribution, controller: 'tasks/asserted_distributions/new_asserted_distribution' do
      get '/', action: :index, as: 'new_asserted_distribution_task'
    end

    scope :new_from_map, controller: 'tasks/asserted_distributions/new_from_map' do
      get 'new', action: 'new', as: 'new_asserted_distribution_from_map_task'
      get 'generate_choices'
      post 'create', action: 'create', as: 'create_asserted_distribution_from_map_task'
    end
  end

  scope :exports do
      scope :taxonworks_project, controller: 'tasks/exports/taxonworks_project' do
        get '/', action: :index, as: 'export_taxonworks_project_task'
        get 'download', as: 'download_taxonworks_project_task'
      end

    scope :coldp, controller: 'tasks/exports/coldp' do
      get '/', action: :index, as: 'export_coldp_task'
      get 'download', as: 'download_coldp_task'
    end

    scope :nomenclature, controller: 'tasks/exports/nomenclature' do
      get 'basic', action: :basic, as: 'export_basic_nomenclature_task'
      get 'download_basic', as: 'download_basic_nomenclature_task'
    end
  end

  scope :matrix_image do
    scope :matrix_image, controller: 'tasks/matrix_image/matrix_image' do
      get :index, as: 'index_matrix_image_task'
    end
  end

  scope :browse_annotations, controller: 'tasks/browse_annotations' do
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
    scope :editor, controller: 'tasks/content/editor' do
      get 'index', as: 'index_editor_task'
      get 'recent_topics', as: 'content_editor_recent_topics_task'
      get 'recent_otus', as: 'content_editor_recent_otus_task'
    end
  end

  scope :descriptors do
    scope :new_descriptor, controller: 'tasks/descriptors/new_descriptor' do
      get '(:descriptor_id)', action: :index, as: 'new_descriptor_task'
    end
  end

  scope :images do
    scope :filter, controller: 'tasks/images/filter' do
      get '/', action: :index, as: 'filter_images_task'
    end

    scope :new_image, controller: 'tasks/images/new_image' do
      get :index, as: 'index_new_image_task'
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

  scope :labels do
    scope :print_labels, controller: 'tasks/labels/print_labels' do
      get '/',  as: 'print_labels_task', action: :index
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

  scope :projects do
    scope :preferences, controller: 'tasks/projects/preferences' do
      get :index, as: 'project_preferences_task'
    end
    scope :data, controller: 'tasks/projects/data' do
      get '/', action: :index, as: 'project_data_task'
    end
  end

  scope :sources do
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
      scope :new_collecting_event, controller: 'tasks/collecting_events/new_collecting_event' do
        get '/', action: :index, as: 'new_collecting_event_task'
      end

    scope :browse, controller: 'tasks/collecting_events/browse' do
      get '/', action: :index, as: 'browse_collecting_events_task'
    end

    scope :filter, controller: 'tasks/collecting_events/filter' do
      get '/', action: :index, as: 'filter_collecting_events_task'
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
  end

  scope :collection_objects do
    scope :match, controller: 'tasks/collection_objects/match' do
      get '/', action: :index, as: 'match_collection_objects_task'
    end

    scope :grid_digitize, controller: 'tasks/collection_objects/grid_digitize' do
      get :index, as: 'grid_digitize_task'
    end

    scope :summary, controller: 'tasks/collection_objects/summary' do
      get '/', action: :index, as: 'collection_object_summary_task'
    end

    scope :filter, controller: 'tasks/collection_objects/filter' do
      get '/', as: 'collection_objects_filter_task', action: :index
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
      scope :work, controller: 'tasks/accessions/report/work' do
        get '/', action: :index, as: 'work_report_task'
        get :data, as: 'work_data_task'
      end

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
    scope :dot, controller: 'tasks/biological_associations/dot' do
      get 'by_project/:project_id', action: :project_dot_graph, as: :biological_associations_dot_graph_task
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
    get 'otu_distribution_data', action: 'show', as: 'otu_distribution_data_task'
  end

  scope :nomenclature do
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

    scope :interactive_key, controller: 'tasks/observation_matrices/interactive_key' do
      get ':observation_matrix_id/key', action: :key, defaults: {format: :json}
      get '', action: :index, as: 'interactive_key_task'
    end

    scope :image_matrix, controller: 'tasks/observation_matrices/image_matrix' do
      get ':observation_matrix_id/key', action: :key, defaults: {format: :json}
      get '', action: :index, as: 'image_matrix_task'
    end
  end

  scope :otus do
    scope :browse_asserted_distributions, controller: 'tasks/otus/browse_asserted_distributions' do
      get :index, as: 'index_browse_asserted_distributions_task'
    end

    scope :browse, controller: 'tasks/otus/browse' do
      get '/(:otu_id)', action: :index, as: 'browse_otus_task'
    end

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

  scope :people, controller: 'tasks/people/author' do
    get 'author', action: 'list', as: 'author_list_task'
    get 'source_list_for_author/:id', action: 'source_list_for_author', as: 'author_source_list_task'
  end

  scope :serials, controller: 'tasks/serials/similar' do
    get 'like(/:id)', action: 'like', as: 'similar_serials_task'
  end

  scope :taxon_names do
    scope :syncronize_otus, controller: 'tasks/taxon_names/syncronize_otus' do
      get 'index', as: 'syncronize_otus_to_nomenclature_task'
      post 'index', as: 'preview_syncronize_otus_to_nomenclature_task'
      post 'syncronize', as: 'syncronize_otus_task'
    end

    scope :filter, controller: 'tasks/taxon_names/filter' do
      get '/', as: 'filter_taxon_names_task', action: :index
    end
  end

  scope :type_material do
    scope :edit_type_material, controller: 'tasks/type_material/edit_type_material' do
      get '/', as: 'edit_type_material_task', action: :index
    end
  end

  scope :uniquify_people, controller: 'tasks/uniquify/people' do
    get 'index', as: 'uniquify_people_task'
  end

  scope :usage, controller: 'tasks/usage/user_activity' do
    get ':id', action: 'report', as: 'user_activity_report_task'
  end
end
