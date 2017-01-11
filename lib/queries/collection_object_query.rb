module Queries

  class CollectionObjectQuery < Queries::Query 


    # find the objects in the selected area
    @geographic_area_id = filter_params[:geographic_area_id] # params[:geographic_area_id]
    @geographic_area    = GeographicArea.find(@geographic_area_id) unless @geographic_area_id.blank?
    @shape_in           = filter_params[:drawn_area_shape] #  params[:drawn_area_shape]

    set_and_order_dates(params)

    if @shape_in.blank? and @geographic_area_id.blank? 
      area_object_ids = CollectionObject.none
      area_set        = false
    else
      area_object_ids = GeographicItem.gather_selected_data(@geographic_area_id, @shape_in, 'CollectionObject').map(&:id)
      area_set        = true
    end

    @otu_id     = params[:otu_id]
    descendants = params[:descendants]
    gather_otu_objects(@otu_id, descendants) # sets @@otu_collection_objects


    # TODO: move all this to the logic of the method 
    if @start_date.blank? || @end_date.blank? #|| area_object_ids.count == 0
      # TODO: This will never get hit, right?!
      @collection_objects = CollectionObject.none
    else
      # TODO: this makes no sense if no date is provided!
      collecting_event_ids = CollectingEvent.in_date_range(date_range_params).pluck(:id)

      # TODO: can be optimized, if no dates provided, then only look for objects by area!
      @collection_objects  = CollectionObject.from_collecting_events(collecting_event_ids,
                                                                     area_object_ids,
                                                                     area_set,
                                                                     sessions_current_project_id).page(params[:page])
    end

    # @collection_objects has to be the intersection
    @otu_co_ids = @otu_collection_objects.map(&:id)
    unless @otu_id.blank?
      @collection_objects = @collection_objects.where(id: @otu_co_ids)
    end
    # @collection_objects = (@collection_objects + @otu_collection_objects).uniq
    @collection_objects_count = @collection_objects.count
    @feature_collection       = ::Gis::GeoJSON.feature_collection(find_georeferences_for(@collection_objects,
                                                                                         @geographic_area))




    #   def where_sql
    #     with_id.or(identified_by).or(with_verbatim_locality).or(with_cached).or(geographic_area_named).to_sql
    #   end

    #   def all 
    #     CollectingEvent.includes(:geographic_area, :identifiers).where(where_sql).references(:geographic_areas, :identifiers).limit(40)
    #   end

    #   def geographic_area_table 
    #     GeographicArea.arel_table
    #   end

    #   def identifier_table
    #     Identifier.arel_table
    #   end

    #   def table
    #     CollectingEvent.arel_table
    #   end

    #   def with_id 
    #     table[:id].eq(@terms.first.to_i)
    #   end

    #   def with_cached
    #     table[:cached].matches_any(@terms)
    #   end

    #   def with_verbatim_trip_code
    #     table[:verbatim_trip_code].eq_any(@terms)
    #   end

    #   def with_verbatim_locality
    #     table[:verbatim_locality].eq_any(@terms)
    #   end

    #   def identified_by
    #     identifier_table[:cached].matches_any(@terms) 
    #   end

    #   def geographic_area_named
    #     geographic_area_table[:name].matches_any(@terms)
    #   end

  end
end
