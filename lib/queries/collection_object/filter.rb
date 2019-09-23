module Queries
  module CollectionObject
    # !! does not inherit from base query

    # TODO 
    # - use date processing?
    # - remove all prepended 'query'
    # - add tests(?) for unchecked params
    # - syncronize with GIS/GEO
  
    # Use DateConcern

    class Filter

      include Queries::Concerns::Tags

      # NO, a query for CE 
      include Queries::Concerns::DateRanges
      
      attr_accessor :recent 

      # [Array]
      attr_accessor :collecting_event_ids

      attr_accessor :collecting_event_query

      # All params managed by CollectingEvent filter are available here as well
     
      # TODO: look for name collisions
      
      # !!!!! Merge with CE filter !!!!! 

      attr_accessor :shape

      attr_accessor :date_partial_overlap # not tested
     
      # replace with date range 
      attr_accessor :query_start_date
      attr_accessor :query_end_date

      attr_accessor :otu_id
      
      attr_accessor :otu_descendants

      attr_accessor :namespace_id
     
      attr_accessor :query_range_start
     
      attr_accessor :query_range_stop
   
      attr_accessor :query_user
  
      attr_accessor :query_date_type_select
 
      attr_accessor :query_user_date_range_end
  
      attr_accessor :query_user_date_range_start
 
      attr_accessor :query_params
      
      # Resolved/processed results
      attr_accessor :start_date, :end_date, :user_date_start, :user_date_end

      # @param [Hash] args
      def initialize(params)
        @query_params = params
        params.reject! { |_k, v| v.blank? } # dump all entries with empty values

        @recent = params[:recent].blank? ? false : true
        @keyword_ids = params[:keyword_ids].blank? ? [] : params[:keyword_ids]

        @collecting_event_ids = params[:collecting_event_id].blank? ? [] : params[:collecting_event_id]

        @collecting_event_query = Queries::CollectingEvent::Filter.new(params)

        @shape = params[:drawn_area_shape]
        @query_start_date      = params[:search_start_date] # TODO: sync key names
        @query_end_date        = params[:search_end_date]
        @otu_id          = params[:otu_id]
        @otu_descendants = params[:descendants]
        @date_partial_overlap  = params[:partial_overlap]
        @namespace_id          = params[:id_namespace]
        @query_range_start           = params[:id_range_start]
        @query_range_stop            = params[:id_range_stop]
        @query_date_type_select      = params[:date_type_select]

        @query_user                  = params[:user]
        @query_user_date_range_start = params[:user_date_range_start]
        @query_user_date_range_end   = params[:user_date_range_end]

        set_and_order_dates
      end

      # @return [Arel::Table]
      def table
        ::CollectionObject.arel_table
      end

      # @return [Arel::Table]
      def collecting_event_table 
        ::CollectingEvent.arel_table
      end

      def tag_table
        ::Tag.arel_table
      end

      # @return Scope
      def collecting_event_ids_facet
        return nil if collecting_event_ids.empty?
        table[:collecting_event_id].eq_any(collecting_event_ids)
      end

      def collecting_event_merge_clauses
        c = []
        
        # Convert base and clauses to merge clauses
        collecting_event_query.base_merge_clauses.each do |i|
          c.push ::CollectionObject.joins(:collecting_event).where( i ) 
        end

        c
      end

      def collecting_event_and_clauses
        c = []

        # Convert base and clauses to merge clauses
        collecting_event_query.base_and_clauses.each do |i|
          c.push ::CollectionObject.joins(:collecting_event).where( i ) 
        end
        c
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          collecting_event_ids_facet
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        clauses = collecting_event_merge_clauses + collecting_event_and_clauses
        # from the simple filter
        clauses += [
          matching_keyword_ids
        ]
        # from the complex query
        clauses = applied_scopes(clauses).compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        # q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::CollectionObject.where(a).distinct
        elsif b
          q = b
        else
          q = ::CollectionObject.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end

      # Only set (and therefor ultimately used) dates if they were provided!
      def set_and_order_dates
        if query_start_date || query_end_date
          @start_date, @end_date = Utilities::Dates.normalize_and_order_dates(query_start_date, query_end_date)
        end
      end

      # @return [Boolean]
      def area_set?
        geographic_area_ids.present?
      end

      # @return [Boolean]
      def date_set?
        start_date.present?
      end

      # @return [Boolean]
      def otu_set?
        otu_id.present?
      end

      # @return [Boolean]
      def shape_set?
        shape.present?
      end

      # @return [Boolean]
      def with_descendants?
        otu_descendants == 'on'
      end

      # @return [Boolean]
      def identifier_set?
        query_range_start.present? || query_range_stop.present?
      end

      # @return [Boolean]
      def user_date_set?
        query_user.present? or (query_user_date_range_start.present? or query_user_date_range_end.present?)
      end

      # All scopes might end up in CollectionObject directly

      # @return [Scope]
      def otu_scope
        # Challenge: Refactor to use a join pattern instead of SELECT IN
        inner_scope = with_descendants? ? ::Otu.self_and_descendants_of(otu_id) : ::Otu.where(id: otu_id)
        ::CollectionObject.joins(:otus).where(otus: {id: inner_scope})
      end

      # @return [Scope]
      def geographic_area_scope
        # This could be simplified if the AJAX selector returned a geographic_item_id rather than a GeographicAreaId
        target_geographic_item_ids = []
        geographic_area_ids.each do |ga_id|
          target_geographic_item_ids.push(::GeographicArea.joins(:geographic_items)
            .find(ga_id)
            .default_geographic_item.id)
        end
        ::CollectionObject.joins(:geographic_items)
          .where(GeographicItem.contained_by_where_sql(target_geographic_item_ids))
      end


      # @return [Scope]
      def shape_scope
        ::GeographicItem.gather_map_data(shape, 'CollectionObject', Current.project_id)       # !!! ARG NO !!!
      end

      # @return [Scope]
      def date_scope
        sql = Queries::CollectingEvent::Filter.new(
          start_date: query_start_date,
          end_date: query_end_date,
          partial_overlap_dates: date_partial_overlap).between_date_range.to_sql
          ::CollectionObject.joins(:collecting_event).where(sql)
      end

      # TODO: remove to IDentifiers concern
      # @return [Scope]
      def identifier_scope
        ns = namespace_id.present? ? ::Namespace.where(short_name: namespace_id).first : nil
        ::CollectionObject.with_identifier_type_and_namespace('Identifier::Local::CatalogNumber', ns, false)
          .where('CAST(identifiers.identifier AS integer) between ? and ?',
                 query_range_start.to_i, query_range_stop.to_i)
      end

      # noinspection RubyResolve
      # @return [Scope]
      def user_date_scope
        @user_date_start, @user_date_end = Utilities::Dates.normalize_and_order_dates(
          query_user_date_range_start,
          query_user_date_range_end)
        
        @user_date_start += ' 00:00:00' # adjust dates to beginning
        @user_date_end   += ' 23:59:59' # and end of date days

        scope = case query_date_type_select
                when 'created_at', nil
                  ::CollectionObject.created_in_date_range(@user_date_start, @user_date_end)
                when 'updated_at'
                  ::CollectionObject.updated_in_date_range(@user_date_start, @user_date_end)
                else
                  ::CollectionObject.all
                end

        unless query_user == 'All users' || query_user == 0
          user_id = ::User.get_user_id(query_user)
          scope = case query_date_type_select
                  when 'created_at'
                    # noinspection RubyResolve
                    scope.created_by_user(user_id)
                  when 'updated_at'
                    scope.updated_by_user(user_id)
                  end
        end
        scope
      end

      # @param [Array] scopes
      # @return [Array] of symbols refering to methods
      #   determine which scopes to apply based on parameters provided
      def applied_scopes(scopes = [])
        # scopes = []
        scopes.push otu_scope if otu_set?
     #   scopes.push geographic_area_scope if area_set?
        scopes.push shape_scope if shape_set?
        scopes.push date_scope if date_set?
        scopes.push identifier_scope if identifier_set?
        scopes.push user_date_scope if user_date_set?
        scopes
      end

      # @return [Scope]
      def result
        return all
      end
    end
  end
end
