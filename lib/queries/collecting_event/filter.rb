module Queries
  module CollectingEvent 

    class Filter 

      # TODO:
      # identifiers

      include Queries::Concerns::Tags
      include Queries::Concerns::DateRanges

      # TODO: likely move to model (replicated in Source too)
      # Params exists for all CollectingEvent attributes except these
      ATTRIBUTES = (::CollectingEvent.column_names - %w{project_id created_by_id updated_by_id created_at updated_at})
      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      # Wildcard wrapped matching any label
      attr_accessor :in_labels

      # If true then in_labels checks only the MD5 
      attr_accessor :md5_verbatim_label

      # TODO: remove for exact/array
      # Wildcard wrapped matching verbatim_locality via ATTRIBUTES
      attr_accessor :in_verbatim_locality

      # TODO: reffactor to Concern or remove (likely doesn't belong here)
      # @return [True, nil]
      attr_accessor :recent

      # A spatial representation in well known text
      attr_accessor :wkt

      # Integer in Meters
      attr_accessor :radius

      # @return [Hash, nil]
      #  in geo_json format (no Feature ...) ?!
      attr_accessor :geo_json

      # @return [True, nil]
      # Reference geographic areas to do a spatial query 
      attr_accessor :spatial_geographic_areas

      # @return [Array]
      #   match only CollectionObjects mapped to CollectingEvents that
      #   have these specific ids.  No spatial calculations are included
      #   in this parameter by default.  See 'spatial_geographic_areas = true'.
      attr_accessor :geographic_area_ids

      # @return [Array]
      #   values are ATTRIBUTES that should be wildcarded
      attr_accessor :collecting_event_wildcards

      # @return [Array]
      attr_accessor :otu_ids

      # @return [Array]
      attr_accessor :collector_ids

      attr_accessor :collector_ids_or

      def initialize(params)
        @in_labels = params[:in_labels]
        @in_verbatim_locality = params[:in_verbatim_locality]
        @recent = params[:recent].blank? ? nil : params[:recent].to_i
      
        @wkt = params[:wkt]
        @geo_json = params[:geo_json]
        @radius = params[:radius].blank? ? 100 : params[:radius] 

        @keyword_ids = params[:keyword_ids].blank? ? [] : params[:keyword_ids]

        # @spatial_geographic_area_ids = params[:spatial_geographic_areas].blank? ? [] : params[:spatial_geographic_area_ids]

        @spatial_geographic_areas = (params[:spatial_geographic_areas]&.downcase == 'true' ? true : false) if !params[:spatial_geographic_areas].nil?

        @md5_verbatim_label = (params[:md5_verbatim_label]&.downcase == 'true' ? true : false) if !params[:md5_verbatim_label].nil?

        @geographic_area_ids = params[:geographic_area_ids].blank? ? [] : params[:geographic_area_ids]

        @otu_ids = params[:otu_ids].blank? ? [] : params[:otu_ids]

        @collector_ids = params[:collector_ids].blank? ? [] : params[:collector_ids]

        @collector_ids_or = (params[:collector_ids_or]&.downcase == 'true' ? true : false) if !params[:collector_ids_or].nil?

        @collecting_event_wildcards = params[:collecting_event_wildcards] || []

        set_attributes(params)
        set_dates(params)
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
        ::CollectingEvent.select('collecting_events.*')
      end

      def attribute_clauses
        c = []
        ATTRIBUTES.each do |a|
          if v = send(a)
            if !v.blank?
              if collecting_event_wildcards.include?(a)
                c.push table[a.to_sym].matches('%' + v.to_s + '%')
              else
                c.push table[a.to_sym].eq(v)
              end
            end
          end
        end
        c
      end

      # TODO: dry with Source, TaxonName, etc.
      def collector_ids_facet
        return nil if collector_ids.empty?
        o = table
        r = ::Role.arel_table

        a = o.alias("a_") 
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
          .and(c[:role_object_type].eq('CollectingEvent'))
          .and(c[:type].eq('Collector'))
        )

        e = c[:id].not_eq(nil)
        f = c[:person_id].eq_any(collector_ids)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(collector_ids.length)) unless collector_ids_or
        b = b.as('z1_')

        ::CollectingEvent.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end


     ## TODO: what is it @param value [String] ?!
     ## In 
     #def shape=(value)
     #  @shape = ::RGeo::GeoJSON.decode(value, json_parser: :json)
     #  @shape
     #end

      def wkt_facet
        return nil if wkt.blank?
        a = RGeo::WKRep::WKTParser.new
        b = a.parse(wkt)
        spatial_query(b.geometry_type.to_s, wkt) 
      end 

      # Shape is a Hash in GeoJSON format
      def geo_json_facet
        return nil if geo_json.nil?
        a = RGeo::GeoJSON.decode(geo_json)
        spatial_query(a.geometry_type.to_s, a.to_s)
      end 

      def spatial_query(geometry_type, wkt)
        case geometry_type 
        when 'Point'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(wkt, radius ))
        when 'Polygon', 'MultiPolygon'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.contained_by_wkt_sql(wkt))
        else
          nil
        end
      end

       # TODO: throttle by size?
       def matching_spatial_via_geographic_area_ids
          return nil unless spatial_geographic_areas && !geographic_area_ids.empty?
          a = ::GeographicItem.default_by_geographic_area_ids(geographic_area_ids).ids 
        ::CollectingEvent.joins(:geographic_items).where( ::GeographicItem.contained_by_where_sql( a ) )
      end

      def matching_any_label
        return nil if in_labels.blank?
        t = "%#{in_labels}%"
        table[:verbatim_label].matches(t).or(table[:print_label].matches(t)).or(table[:document_label].matches(t))
      end

      def matching_verbatim_label_md5
        return nil unless md5_verbatim_label && !in_labels.blank?
        md5 = ::Utilities::Strings.generate_md5(in_labels) 

        table[:md5_of_verbatim_label].eq(md5)
      end

      def matching_geographic_area_ids
        return nil if geographic_area_ids.empty? || spatial_geographic_areas
        table[:geographic_area_id].eq_any(geographic_area_ids)
      end

      def matching_otu_ids
        return nil if otu_ids.empty?
        ::CollectingEvent.joins(:otus).where(otus: {id: otu_ids}) #  table[:geographic_area_id].eq_any(geographic_area_ids)
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
          matching_verbatim_label_md5,
          matching_any_label,
          matching_verbatim_locality,
        ].compact!

        clauses
      end

      def base_merge_clauses
        clauses = [
          keyword_id_facet, 
          matching_otu_ids,
          wkt_facet,
          geo_json_facet,
          collector_ids_facet,
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
          q = ::CollectingEvent.includes(:identifiers, :roles, :pinboard_items, :geographic_area, georeferences: [:geographic_item, :error_geographic_item]).all
        end
        
        q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end
    end
    
  end
end
