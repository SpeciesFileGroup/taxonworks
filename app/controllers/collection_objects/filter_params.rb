module CollectionObjects
  module FilterParams
    private

    def filtered_collection_objects
      # !! Do not add order() here, it breaks DwC integration
      ::Queries::CollectionObject::Filter.
        new(collection_object_filter_params).all.where(project_id: sessions_current_project_id)

        # Apply pagination during use
        # page(params[:page]).per(params[:per] || 500)
    end

    def collection_object_filter_params
      a = params.permit(
        :recent,
        ::Queries::CollectingEvent::Filter::ATTRIBUTES,
        :ancestor_id,
        :buffered_collecting_event,
        :buffered_determinations,
        :buffered_other_labels,
        :collecting_event,
        :collection_object_type,
        :collector_ids_or,
        :current_determinations,
        :depictions,
        :determiner_id_or,
        :dwc_indexed,
        :end_date,
        :exact_buffered_collecting_event,
        :exact_buffered_determinations,
        :exact_buffered_other_labels,
        :geo_json,
        :geographic_area,
        :georeferences,
        :identifier,
        :identifier_end,
        :identifier_exact,
        :identifier_start,
        :identifiers,
        :in_labels,
        :in_verbatim_locality,
        :loaned,
        :md5_verbatim_label,
        :namespace_id,
        :never_loaned,
        :object_global_id,
        :on_loan,
        :partial_overlap_dates,
        :preparation_type_id,
        :radius,  # CE filter
        :repository,
        :repository_id,
        :sled_image_id,
        :spatial_geographic_areas,
        :start_date,  # CE filter
        :taxon_determination_id,
        :taxon_determinations,
        :type_material,
        :type_specimen_taxon_name_id,
        :user_date_end,
        :user_date_start,
        :user_id,
        :user_target,
        :validity,
        :with_buffered_collecting_event,
        :with_buffered_determinations,
        :with_buffered_other_labels,
        :wkt,
        biocuration_class_ids: [],
        biological_relationship_ids: [],
        collecting_event_ids: [],
        collector_ids: [], #
        determiner_id: [],
        geographic_area_id: [],
        is_type: [],
        keyword_id_and: [],
        keyword_id_or: [],
        otu_ids: [],
        preparation_type_id: []
        #  user_id: []
        #  collecting_event: {
        #   :recent,
        #   keyword_id_and: []
        # }
      )

      # TODO: check user_id: []

      a[:user_id] = params[:user_id] if params[:user_id] && is_project_member_by_id(params[:user_id], sessions_current_project_id) # double check vs. setting project_id from API
      a
    end

    def collection_object_api_params
      a = params.permit(
        :recent,
        ::Queries::CollectingEvent::Filter::ATTRIBUTES,
        :ancestor_id,
        :buffered_collecting_event,
        :buffered_determinations,
        :buffered_other_labels,
        :collecting_event,
        :collection_object_type,
        :collector_ids_or,
        :current_determinations,
        :depictions,
        :determiner_id_or,
        :dwc_indexed,
        :end_date,  # CE filter
        :exact_buffered_collecting_event,
        :exact_buffered_determinations,
        :exact_buffered_other_labels,
        :geo_json,
        :geographic_area,
        :georeferences,
        :identifier,
        :identifier_end,
        :identifier_exact,
        :identifier_start,
        :identifiers,
        :in_labels,
        :in_verbatim_locality,
        :loaned,
        :md5_verbatim_label, # CE filter
        :namespace_id,
        :never_loaned,
        :on_loan,
        :partial_overlap_dates, # CE filter
        :preparation_type_id,
        :radius,
        :repository,
        :repository_id,
        :sled_image_id,
        :spatial_geographic_areas,
        :start_date,
        :taxon_determinations,
        :type_material,
        :type_specimen_taxon_name_id,
        :user_date_end,
        :user_date_start,
        :user_id,
        :user_target,
        :validity,
        :with_buffered_collecting_event,
        :with_buffered_determinations,
        :with_buffered_other_labels,
        :wkt, # CE filter
        biocuration_class_ids: [],
        biological_relationship_ids: [],
        collecting_event_ids: [],
        collector_ids: [],
        determiner_id: [],
        geographic_area_id: [], # CE filter
        is_type: [],
        keyword_id_and: [],
        keyword_id_or: [],
        otu_ids: [],
        preparation_type_id: [],

        #  collecting_event: {
        #   :recent,
        #   keyword_id_and: []
        # }
      )

      a[:user_id] = params[:user_id] if params[:user_id] && is_project_member_by_id(params[:user_id], sessions_current_project_id) # double check vs. setting project_id from API
      a
    end
  end
end
