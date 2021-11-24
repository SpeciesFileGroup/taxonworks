module Queries
  module CollectingEvent
    class Filter
      include Queries::Helpers

      include Queries::Concerns::Tags
      include Queries::Concerns::DateRanges
      include Queries::Concerns::Identifiers

      # TODO: likely move to model (replicated in Source too)
      # Params exists for all CollectingEvent attributes except these
      ATTRIBUTES = (::CollectingEvent.column_names - %w{project_id created_by_id updated_by_id created_at updated_at geographic_area_id})
      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      PARAMS = %w{collector_id
        collector_ids_or
        spatial_geographic_areas
        wkt
        geographic_area_id
        start_date
        end_date
        radius
        partial_overlap_dates
        md5_verbatim_label
        in_verbatim_locality
        in_labels
        geo_json
      }

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
      attr_accessor :geographic_area_id

      # @return [Array]
      #   values are ATTRIBUTES that should be wildcarded
      attr_accessor :collecting_event_wildcards

      # DONE: singularize and handle array or single
      # @return [Array]
      attr_accessor :otu_id

      # DONE: singularize and handle array or single
      # @return [Array]
      attr_accessor :collector_id

      # @return [Boolean]
      # @param collector_ids_or [String]
      #   'true' - all ids treated as "or"
      #   'false', nil - all ids treated as "and"
      attr_accessor :collector_ids_or

      # @param collection_objects [String, nil]
      #   legal values are 'true', 'false'
      #   `true` - match only CollectingEvents with associated CollectionObjects
      #   `false` - match only CollectingEvents without associated CollectionObjects
      # @return collection_objects [Boolean, nil]
      #
      #  whether the CollectingEvent has associated CollectionObjects
      attr_accessor :collection_objects

      def initialize(params)
        # @spatial_geographic_area_ids = params[:spatial_geographic_areas].blank? ? [] : params[:spatial_geographic_area_ids]

        @collecting_event_wildcards = params[:collecting_event_wildcards] || []
        @collector_id = params[:collector_id]
        @collector_ids_or = boolean_param(params, :collector_ids_or )
        @collection_objects = boolean_param(params, :collection_objects )
        @geo_json = params[:geo_json]
        @geographic_area_id = params[:geographic_area_id]
        @in_labels = params[:in_labels]
        @in_verbatim_locality = params[:in_verbatim_locality]
        @md5_verbatim_label = (params[:md5_verbatim_label]&.downcase == 'true' ? true : false) if !params[:md5_verbatim_label].nil?
        @otu_id = params[:otu_id].blank? ? [] : params[:otu_id]
        @radius = params[:radius].blank? ? 100 : params[:radius]
        @recent = params[:recent].blank? ? nil : params[:recent].to_i
        @spatial_geographic_areas = (params[:spatial_geographic_areas]&.downcase == 'true' ? true : false) if !params[:spatial_geographic_areas].nil?
        @wkt = params[:wkt]

        set_identifier(params)
        set_tags_params(params)
        set_attributes(params)
        set_dates(params)
      end

      def set_attributes(params)
        ATTRIBUTES.each do |a|
          send("#{a}=", params[a.to_sym])
        end
      end

      def collector_id
        [@collector_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
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
                c.push Arel::Nodes::NamedFunction.new("CAST", [table[a.to_sym].as("TEXT")]).matches('%' + v.to_s + '%')
              else
                c.push table[a.to_sym].eq(v)
              end
            end
          end
        end
        c
      end

      # @return Scope
      def collection_objects_facet
        return nil if collection_objects.nil?
        subquery = ::CollectionObject.where(::CollectionObject.arel_table[:collecting_event_id].eq(::CollectingEvent.arel_table[:id])).arel.exists
        ::CollectingEvent.where(collection_objects ? subquery : subquery.not)
      end

      # TODO: dry with Source, TaxonName, etc.
      def collector_ids_facet
        return nil if collector_id.empty?
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
        f = c[:person_id].eq_any(collector_id)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(collector_id.length)) unless collector_ids_or
        b = b.as('col_z_')

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
        return nil unless spatial_geographic_areas && !geographic_area_id.empty?
        a = ::GeographicItem.default_by_geographic_area_ids(geographic_area_id).ids
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

      def matching_geographic_area_id
        return nil if geographic_area_id.empty? || spatial_geographic_areas
        table[:geographic_area_id].eq_any(geographic_area_id)
      end

      def matching_otu_ids
        return nil if otu_id.empty?
        ::CollectingEvent.joins(:otus).where(otus: {id: otu_id}) #  table[:geographic_area_id].eq_any(geographic_area_ids)
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
          matching_geographic_area_id,
          matching_verbatim_label_md5,
          matching_any_label,
          matching_verbatim_locality,
        ].compact!

        clauses
      end

      def base_merge_clauses
        clauses = [
          collection_objects_facet,
          keyword_id_facet,
          matching_otu_ids,
          wkt_facet,
          geo_json_facet,
          collector_ids_facet,
          matching_spatial_via_geographic_area_ids,
          identifiers_facet,      # See Queries::Concerns::Identifiers
          identifier_between_facet,
          identifier_facet, # See Queries::Concerns::Identifiers
          identifier_namespace_facet,
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
