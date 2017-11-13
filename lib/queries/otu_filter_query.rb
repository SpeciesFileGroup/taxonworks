module Queries

  class OtuFilterQuery < Queries::Query

    # Query variables
    attr_accessor :query_geographic_area_ids, :query_shape
    attr_accessor :query_date_partial_overlap, :query_start_date, :query_end_date
    attr_accessor :query_otu_id, :query_descendants
    attr_accessor :query_author_id
    attr_accessor :query_id_namespace, :query_range_start, :query_range_stop
    attr_accessor :query_user, :query_date_type_select,
                  :query_user_date_range_end, :query_user_date_range_start


    # Reolved/processed results
    attr_accessor :start_date, :end_date, :user_date_start, :user_date_end

    def initialize(params)
      params.reject! { |k, v| v.blank? }

      @query_geographic_area_ids = params[:geographic_area_ids]
      @query_shape               = params[:drawn_area_shape]
      @query_author_id           = params[:author_id]
      @query_otu_id              = params[:otu_id]
      @query_descendants         = params[:descendants]

      @query_end_date              = params[:search_end_date]
      @query_date_partial_overlap  = params[:partial_overlap]
      @query_id_namespace          = params[:id_namespace]
      @query_range_start           = params[:id_range_start]
      @query_range_stop            = params[:id_range_stop]
      @query_user                  = params[:user]
      @query_date_type_select      = params[:date_type_select]
      @query_user_date_range_start = params[:user_date_range_start]
      @query_user_date_range_end   = params[:user_date_range_end]

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

    def author_set?
      !query_author_id.nil?
    end

    def otu_set?
      !query_otu_id.nil?
    end

    def shape_set?
      !query_shape.nil?
    end

    def with_descendants?
      query_descendants == 'on'
    end

    def identifier_set?
      query_range_start.present? || query_range_stop.present?
    end

    def user_date_set?
      # query_date_type_select.present? or
      query_user.present? or
        (query_user_date_range_start.present? or query_user_date_range_end.present?)
    end

    # All scopes might end up in Otu directly

    # @return [Scope]
    def otu_scope
      # Challenge: Refactor to use a join pattern instead of SELECT IN
      innerscope = with_descendants? ? Otu.self_and_descendants_of(query_otu_id) : Otu.where(id: query_otu_id)
      # Otu.where(id: innerscope)
      innerscope
    end

=begin
      1. find all geographic_items in area(s)/shape
      2. find all georeferences which are associated with result #1
      3. find all collecting_events which are associated with result #2
      4. find all collection_objects which are associated with result #3
      5. find all otus which are associated with result #4
=end
    # @return [Scope]
    def geographic_area_scope
      # This could be simplified if the AJAX selector returned a geographic_item_id rather than a GeographicAreaId
      target_geographic_item_ids = []
      query_geographic_area_ids.each do |gaid|
        target_geographic_item_ids.push(GeographicArea.joins(:geographic_items).find(gaid).default_geographic_item.id)
      end
      # r4 = CollectionObject.joins(:geographic_items)
      #        .where(GeographicItem.contained_by_where_sql(target_geographic_item_ids))
      r42i = CollectionObject.joins(:geographic_items)
               .where(GeographicItem.contained_by_where_sql(target_geographic_item_ids))
               .distinct
               .pluck(:id)
      # get the Otus associated with r4
      # r5i = r4.map(&:otus).flatten.pluck(:id).uniq
      # r5o = Otu.where(id: r5i)
      r5o2 = Otu.joins(:collection_objects).where('biological_collection_object_id in (?)', r42i)
      # r5o
      r5o2
    end

    # @return [Scope]
    def shape_scope
      # r4   = GeographicItem.gather_map_data(query_shape, 'CollectionObject')
      r42i = GeographicItem.gather_map_data(query_shape, 'CollectionObject')
               .distinct
               .pluck(:id)
      # get the Otus associated with r4
      # r5i = r4.map(&:otus).flatten.pluck(:id).uniq
      # r5o = Otu.where(id: r5i)
      r5o2 = Otu.joins(:collection_objects).where('biological_collection_object_id in (?)', r42i)
      # r5o
      r5o2
    end

    # @return [Scope]
    def nomenclature_scope
      Otu.where(taxon_name: taxon_name)
      #date_sql_from_dates(start_date, end_date, query_date_partial_overlap ))
    end

=begin
      1. find all people from params
      2. find all people with role TaxonNameAuthor from result #1
      3. find all taxon_names which are associated with result #2
      4. find all otus which are associated with result #3
=end
    # @return [Scope]
    def author_scope
      # Otu.joins(:collecting_event).where(CollectingEvent.date_sql_from_dates(start_date, end_date, query_date_partial_overlap))
      # r1 = Person.collect(*query_author_ids)
      r2 =
        Otu.joins(:collecting_event).where(CollectingEvent.date_sql_from_dates(start_date, end_date, query_date_partial_overlap))
      #date_sql_from_dates(start_date, end_date, query_date_partial_overlap ))
    end

    # @return [Array]
    #   determine which scopes to apply based on parameters provided
    def applied_scopes
      scopes = []
      scopes.push :geographic_area_scope if area_set?
      scopes.push :shape_scope if shape_set?
      scopes.push :otu_scope if otu_set?
      scopes.push :author_scope if author_set?
      # scopes.push :identifier_scope if identifier_set?
      # scopes.push :user_date_scope if user_date_set?
      scopes
    end

    # @return [Scope]
    def result
      return Otu.none if applied_scopes.empty?
      a = Otu.all
      applied_scopes.each do |scope|
        a = a.merge(self.send(scope))
      end
      a
    end
  end
end
