scope :tasks do

  scope :exports do
    scope :coldp, controller: 'tasks/exports/coldp' do
      get 'index', as: 'export_coldp_task'
      get 'download', as: 'download_coldp_task'
    end
  end

  scope :matrix_image do
    scope :matrix_image, controller: 'tasks/matrix_image/matrix_image' do
      get :index, as: 'index_matrix_image_task'
    end
  end

  scope :asserted_distribution do
    scope :new_asserted_distribution, controller: 'tasks/asserted_distribution/new_asserted_distribution' do
      get :index, as: 'index_new_asserted_distribution_task'
    end
  end

  scope :browse_annotations, controller: 'tasks/browse_annotations' do
    get 'index', as: 'browse_annotations_task'
  end

  scope :citations do
    scope :otus, controller: 'tasks/citations/otus' do
      get 'index', as: 'cite_otus_task_task'
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
      get :index, as: 'index_print_labels_task'
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
  end

  scope :sources do
    scope :hub, controller: 'tasks/sources/hub' do
      get :index, as: 'index_hub_task'
    end

    scope :individual_bibtex_source, controller: 'tasks/sources/individual_bibtex_source' do
      get 'index', as: 'index_individual_bibtex_source_task'
    end

    scope :browse, controller: 'tasks/sources/browse' do
      get 'index', as: 'browse_sources_task'
      get 'find', as: 'find_sources_task'
    end
  end

  scope :collecting_events do
    scope :search_locality, controller: 'tasks/collecting_events/search_locality' do
      get 'index', as: 'index_search_locality_task'
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
      # needs a name to remove conflicts?
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
    get 'otu_distribution_data', action: 'show', as: 'otu_distribution_data_task'
  end

  scope :nomenclature do
      scope :stats, controller: 'tasks/nomenclature/stats' do
        get :index, as: 'index_stats_task'
      end

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
      get '', action: :index, as: 'browse_nomenclature_task'
    end

    scope :by_source, controller: 'tasks/nomenclature/by_source' do
      get '(:source_id)', action: :index, as: 'nomenclature_by_source_task'
    end
  end

  scope :observation_matrices do
      scope :dashboard, controller: 'tasks/observation_matrices/dashboard' do
        get :index, as: 'index_dashboard_task'
      end


    scope :view, controller: 'tasks/observation_matrices/view' do
      get '(:observation_matrix_id)', as: 'observation_matrix_view_task', action: :index
    end

    scope :observation_matrix_hub, controller: 'tasks/observation_matrices/observation_matrix_hub' do
      get 'index', as: 'observation_matrices_hub_task' # 'index_observation_matrix_hub_task'
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
    scope :filter, controller: 'tasks/taxon_names/filter' do
      get :index, as: 'index_filter_task'
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
