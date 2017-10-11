module Queries

  class CollectionObjectFilterQuery < Queries::Query

    # Query variables
    attr_accessor :query_geographic_area_ids, :query_shape
    attr_accessor :query_date_partial_overlap, :query_start_date, :query_end_date
    attr_accessor :query_otu_id, :query_otu_descendants
    attr_accessor :query_id_namespace, :query_range_start, :query_range_stop
    attr_accessor :query_user, :query_date_type_select,
                  :query_user_date_range_end, :query_user_date_range_start


    # Reolved/processed results
    attr_accessor :start_date, :end_date, :user_date_start, :user_date_end

    def initialize(params)
      params.reject! { |k, v| v.blank? }

      @query_geographic_area_ids   = params[:geographic_area_ids]
      @query_shape                 = params[:drawn_area_shape]
      @query_start_date            = params[:search_start_date] # TODO: sync key names
      @query_end_date              = params[:search_end_date]
      @query_otu_id                = params[:otu_id]
      @query_otu_descendants       = params[:descendants] # .downcase if params[:descendants] # TODO: remove downcase requirement
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

    def user_date_set?
      # query_date_type_select.present? or
      query_user.present? or
        (query_user_date_range_start.present? or query_user_date_range_end.present?)
    end

    # All scopes might end up in CollectionObject directly

    # @return [Scope]
    def otu_scope
      # Challenge: Refactor to use a join pattern instead of SELECT IN
      innerscope = with_descendants? ? Otu.self_and_descendants_of(query_otu_id) : Otu.where(id: query_otu_id)
      CollectionObject.joins(:otus).where(otus: {id: innerscope})
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
      ns = nil
      ns = Namespace.where(short_name: query_id_namespace).first if query_id_namespace.present?
      CollectionObject.with_identifier_type_and_namespace('Identifier::Local::CatalogNumber', ns, true)
        .where("CAST(identifiers.identifier AS integer) between ? and ?",
               query_range_start.to_i, query_range_stop.to_i)
    end

    def user_date_scope
      @user_date_start, @user_date_end = Utilities::Dates.normalize_and_order_dates(query_user_date_range_start,
                                                                                    query_user_date_range_end)

      scope = case query_date_type_select
                when 'created_at', nil
                  CollectionObject.created_in_date_range(@user_date_start, @user_date_end)
                when 'updated_at'
                  CollectionObject.updated_in_date_range(@user_date_start, @user_date_end)
                else
                  CollectionObject.all
              end

      if query_user != 'All users'
        user_id = User.find_user_id(query_user)
        scope   = case query_date_type_select
                    when 'created_at'
                      scope.created_by_user(user_id)
                    when 'updated_at'
                      scope.updated_by_user(user_id)
                  end
      end
      scope
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
      scopes.push :user_date_scope if user_date_set?
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
