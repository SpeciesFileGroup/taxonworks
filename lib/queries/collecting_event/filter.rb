module Queries
  module CollectingEvent 

    # !! does not inherit from base query
    class Filter 

      include Queries::Concerns::DateRanges

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

      attr_accessor :keyword_ids

      # TODO:
      # identifiers

      # An RGeo::GeoJSON feature
      attr_accessor :shape

      # Reference geographic areas to do a spatial query 
      attr_accessor :spatial_geographic_area_ids

      def initialize(params)
        @in_label = params[:in_labels]
        @in_verbatim_locality = params[:in_verbatim_locality]
        @recent = params[:recent].blank? ? nil : params[:recent].to_i
        self.shape = params[:shape]

        @keyword_ids = params[:keyword_ids].blank? ? [] : params[:keyword_ids]
        @spatial_geographic_area_ids = params[:spatial_geographic_area_ids].blank? ? [] : params[:spatial_geographic_area_ids]

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

      def tag_table
        ::Tag.arel_table
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

      def matching_keyword_ids
        return nil if keyword_ids.empty?
        o = table
        t = ::Tag.arel_table

        a = o.alias("a_")
        b = o.project(a[Arel.star]).from(a)

        c = t.alias('t1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:tag_object_id])
          .and(c[:tag_object_type].eq(table.name.classify))
        )

        e = c[:keyword_id].not_eq(nil)
        f = c[:keyword_id].eq_any(keyword_ids)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.as('tz5_')

        _a = ::CollectingEvent.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
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

      def matching_verbatim_locality
        return nil if in_verbatim_locality.blank?
        t = "%#{in_verbatim_locality}%"
        table[:verbatim_locality].matches(t)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []
        clauses += attribute_clauses
       
        clauses += [
          between_date_range,
          matching_any_label,
          matching_verbatim_locality,
        ].compact
        
        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def merge_clauses
        clauses = [
          matching_keyword_ids,
          matching_shape,
          matching_spatial_via_geographic_area_ids

          # matching_verbatim_author
        ].compact

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
  
      protected

    end
  end
end
