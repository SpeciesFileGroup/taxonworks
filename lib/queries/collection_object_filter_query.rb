module Queries

  class CollectionObjectFilterQuery < Queries::Query 

    # Query variables
    attr_accessor :query_geographic_area_id, :query_shape
    attr_accessor :query_date_partial_overlap, :query_start_date, :query_end_date
    attr_accessor :query_otu_id, :query_otu_descendants

    # Reolved/processed results
    attr_accessor :start_date, :end_date

    def initialize(params)
      params.reject!{|k, v| v.blank?}

      @query_geographic_area_id = params[:geographic_area_id]
      @query_shape = params[:drawn_area_shape]
      @query_start_date = params[:search_start_date] # TODO: sync key names
      @query_end_date = params[:search_end_date]
      @query_otu_id = params[:otu_id]
      @query_otu_descendants = params[:descendants] # .downcase if params[:descendants] # TODO: remove downcase requirement
      @query_date_partial_overlap = params[:partial_overlap]

      set_and_order_dates
    end

    # Only set (and therefor ultimately use) dates if they were provided!
    def set_and_order_dates
      if query_start_date || query_end_date
        @start_date, @end_date = Utilities::Dates.normalize_and_order_dates(query_start_date, query_end_date)
      end
    end

    def area_set?
      !query_geographic_area_id.nil?
    end

    def date_set?
      !start_date.nil? 
    end

    def otu_set?
      !query_otu_id.nil?
    end

    def shape_set?
      !query_shape.nil?
    end

    def with_descendants?
      query_otu_descendants == 'on'
    end

    # All scopes might end up in CollectionObject directly

    # @return [Scope]
    def otu_scope 
      # Challenge: Refactor to use a join pattern instead of SELECT IN
      innerscope = with_descendants? ? Otu.self_and_descendants_of(query_otu_id) : Otu.where(id: query_otu_id) 
      CollectionObject.joins(:otus).where(otus: {id: innerscope} )
    end

    # @return [Scope]
    def geographic_area_scope
      # This could be simplified if the AJAX selector returned a geographic_item_id rather than a GeographicAreaId
      target_geographic_item_id = GeographicArea.joins(:geographic_items).find(query_geographic_area_id).default_geographic_item.to_param
      CollectionObject.joins(:geographic_items).where(GeographicItem.contained_by_where_sql(target_geographic_item_id))     
    end

    # @return [Scope]
    def shape_scope
      GeographicItem.gather_map_data(query_shape, 'CollectionObject')
    end 

    # @return [Scope]
    def date_scope
      CollectionObject.joins(:collecting_event).where(CollectingEvent.date_sql_from_dates(start_date, end_date, query_date_partial_overlap ))  
  #date_sql_from_dates(start_date, end_date, query_date_partial_overlap ))  
    end

    # @return [Array]
    #   determine which scopes to apply based on parameters provided
    def applied_scopes
      scopes = []
      scopes.push :otu_scope if otu_set?
      scopes.push :geographic_area_scope if area_set?
      scopes.push :shape_scope if shape_set?
      scopes.push :date_scope if date_set? 
      scopes
    end

    # @return [Scope]
    def result
      return CollectionObject.none if applied_scopes.empty?
      a = CollectionObject.all
      applied_scopes.each do |scope|
        a = a.merge(self.send(scope))
      end
      a
    end
  end
end
