module Queries

  class CollectionObjectFilterQuery < Queries::Query

    # Query variables
    attr_accessor :query_geographic_area_ids, :query_shape
    attr_accessor :query_date_partial_overlap, :query_start_date, :query_end_date
    attr_accessor :query_otu_id, :query_otu_descendants
    attr_accessor :query_id_namespace, :query_range_start, :query_range_stop

    # Reolved/processed results
    attr_accessor :start_date, :end_date

    def initialize(params)
      params.reject!{|k, v| v.blank?}

      @query_geographic_area_ids = params[:geographic_area_ids]
      @query_shape = params[:drawn_area_shape]
      @query_start_date = params[:search_start_date] # TODO: sync key names
      @query_end_date = params[:search_end_date]
      @query_otu_id = params[:otu_id]
      @query_otu_descendants = params[:descendants] # .downcase if params[:descendants] # TODO: remove downcase requirement
      @query_date_partial_overlap = params[:partial_overlap]
      @query_id_namespace = params[:id_namespace]
      @query_range_start = params[:range_start]
      @query_range_stop = params[:range_stop]

      set_and_order_dates
    end

    # Only set (and therefor ultimately use) dates if they were provided!
    def set_and_order_dates
      if query_start_date || query_end_date
        @start_date, @end_date = Utilities::Dates.normalize_and_order_dates(query_start_date, query_end_date)
      end
    end

    def area_set?
      !query_geographic_area_ids.nil?
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

    def identifier_set?
      query_range_start.present? || query_range_stop.present?
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
      target_geographic_item_ids = []
      query_geographic_area_ids.each do |gaid|
        target_geographic_item_ids.push(GeographicArea.joins(:geographic_items).find(gaid).default_geographic_item.id)
      end
      CollectionObject.joins(:geographic_items).where(GeographicItem.contained_by_where_sql(target_geographic_item_ids))
    end

    # @return [Scope]
    def shape_scope
      GeographicItem.gather_map_data(query_shape, 'CollectionObject')
    end

    # @return [Scope]
    def date_scope
      CollectionObject.joins(:collecting_event).where(CollectingEvent.date_sql_from_dates(start_date, end_date, query_date_partial_overlap))
      #date_sql_from_dates(start_date, end_date, query_date_partial_overlap ))
    end

    def identifier_scope
      ns = Namespace.where(short_name: @query_id_namespace).first
      CollectionObject.with_identifier_type_and_namespace('Identifier::Local::CatalogNumber', ns, true)
          .where("CAST(identifiers.identifier AS integer) between ? and ?", query_range_start.to_i, query_range_stop.to_i)
    end

    # @return [Array]
    #   determine which scopes to apply based on parameters provided
    def applied_scopes
      scopes = []
      scopes.push :otu_scope if otu_set?
      scopes.push :geographic_area_scope if area_set?
      scopes.push :shape_scope if shape_set?
      scopes.push :date_scope if date_set?
      scopes.push :identifier_scope if identifier_set?
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
