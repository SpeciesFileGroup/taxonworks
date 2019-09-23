module Queries
  module CollectingEvent 

    class Filter 

      # TODO:
      # identifiers

      include Queries::Concerns::Tags
      include Queries::Concerns::DateRanges

      # Params exists for all CollectingEvent attributes except these
      ATTRIBUTES = (::CollectingEvent.column_names - %w{project_id created_by_id updated_by_id created_at updated_at})
      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      # Wildcard wrapped matching any label
      attr_accessor :in_labels

      # Wildcard wrapped matching verbatim_locality
      attr_accessor :in_verbatim_locality

      # TODO: factor to include
      # An integer, order result and return the last :recent records
      attr_accessor :recent

      # An RGeo::GeoJSON feature
      attr_accessor :shape

      # Reference geographic areas to do a spatial query 
      # TODO: deprecate
      attr_accessor :spatial_geographic_area_ids

      # [Array]
      #   match only CollectionObjects mapped to CollectingEvents that
      #   have these specific ids.  No spatial calculations are included
      #   in this parameter by default.  See 'spatial_geographic_areas = true'.
      attr_accessor :geographic_area_ids # not tested



      def initialize(params)
        @in_labels = params[:in_labels]
        @in_verbatim_locality = params[:in_verbatim_locality]
        @recent = params[:recent].blank? ? nil : params[:recent].to_i
        self.shape = params[:shape]

        @keyword_ids = params[:keyword_ids].blank? ? [] : params[:keyword_ids]
        @spatial_geographic_area_ids = params[:spatial_geographic_area_ids].blank? ? [] : params[:spatial_geographic_area_ids]

        @geographic_area_ids = params[:geographic_area_ids].blank? ? [] : params[:geographic_area_ids]

        set_attributes(params)
        set_dates(params)
      end

      def shape=(value)
        @shape = ::RGeo::GeoJSON.decode(value, json_parser: :json)
        @shape
      end

      def set_attributes(params)
        ATTRIBUTES.each do |a|
          send("#{a}=", params[a.to_sym]) 
        end
      end

      # @return [Arel::Table]
      def table
        ::CollectingEvent.arel_table
      end
      
      def base_query
        ::CollectingEvent
      end

      def attribute_clauses
        c = []
        ATTRIBUTES.each do |a|
          if v = send(a)
            c.push table[a.to_sym].eq(v) if !v.blank?
          end
        end
        c
      end

      def matching_shape
        return nil if shape.nil?

        geometry = shape.geometry
        this_type = geometry.geometry_type.to_s.downcase
        geometry = geometry.as_text
        radius = shape['radius'] || 100

        case this_type
        when 'point'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(geometry, radius ))
        when 'polygon'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.contained_by_wkt_sql(geometry))
        else
          nil
        end
      end 

      # TODO: throttle by size?
      def matching_spatial_via_geographic_area_ids
        return nil if spatial_geographic_area_ids.empty? 
        a = ::GeographicItem.default_by_geographic_area_ids(spatial_geographic_area_ids).ids 
        ::CollectingEvent.joins(:geographic_items).where( ::GeographicItem.contained_by_where_sql( a ) )
      end

      def matching_any_label
        return nil if in_labels.blank?
        t = "%#{in_labels}%"
        table[:verbatim_label].matches(t).or(table[:print_label].matches(t)).or(table[:document_label].matches(t))
      end

      def matching_geographic_area_ids
        return nil if geographic_area_ids.empty? || spatial_geographic_area_ids.any? # BLOCKER TODO: update to match BOOLEAN
        table[:geographic_area_id].eq_any(geographic_area_ids)
      end

      def matching_verbatim_locality
        return nil if in_verbatim_locality.blank?
        t = "%#{in_verbatim_locality}%"
        table[:verbatim_locality].matches(t)
      end

      # @return [Array]
      def base_and_clauses
        clauses = []
        clauses += attribute_clauses

        clauses += [
          between_date_range,
          matching_geographic_area_ids,
          matching_any_label,
          matching_verbatim_locality,
        ].compact!

        clauses
      end

      def base_merge_clauses
        clauses = [
          matching_keyword_ids,
          matching_shape,
          matching_spatial_via_geographic_area_ids
        ].compact!
        clauses
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = base_and_clauses        
        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def merge_clauses
        clauses = base_merge_clauses
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

        q = nil 
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::CollectingEvent.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::CollectingEvent.all
        end
        
        q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end
    end
    
  end
end
