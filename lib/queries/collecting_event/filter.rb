module Queries
  module CollectingEvent
    class Filter < Query::Filter
      include Queries::Helpers

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes
      include Queries::Concerns::DateRanges
      include Queries::Concerns::DataAttributes

      # TODO: likely move to model (replicated in Source too) and setup via macro?
      # Params exists for all CollectingEvent attributes except these.
      # collecting_event_id is excluded because we handle it specially in conjunction with `geographic_area_mode``
      ATTRIBUTES = (::CollectingEvent.core_attributes - %w{geographic_area_id}).map(&:to_sym).freeze

      # This is still used in CollectionObject query.
      # !!
      # !! There is likely some collision with wkt, other shared variables
      # !!
      BASE_PARAMS = %i{
        collecting_event_object_id
        collecting_event_wildcards
        collection_objects
        collector_id
        collector_id_or
        depictions
        determiner_name_regex
        end_date
        geo_json
        geographic_area
        geographic_area_id
        geographic_area_mode
        georeferences
        in_labels
        in_verbatim_locality
        md5_verbatim_label
        otu_id
        partial_overlap_dates
        radius
        start_date
        wkt
      }.freeze

      PARAMS = [
        *ATTRIBUTES,
        *BASE_PARAMS,
        collecting_event_wildcards: [],
        collection_object_id: [],
        collector_id: [],
        geographic_area_id: [],
        otu_id: [],
        collecting_event_id: [],
      ].freeze # not needed right now# .flatten.sort{|a,b| a.is_a?(Hash) ? 1 : 0  <=> b.is_a?(Hash) ? 1 : 0}.uniq!.freeze

      # All collecting event fields have their own accessor.
      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      # @param collecting_event_id [ Array, Integer, nil]
      #   One or more collecting_event_id
      attr_accessor :collecting_event_id

      # Wildcard wrapped matching any label
      attr_accessor :in_labels

      # If true then in_labels checks only the MD5
      attr_accessor :md5_verbatim_label

      # TODO: remove for exact/array
      # Wildcard wrapped matching verbatim_locality via ATTRIBUTES
      attr_accessor :in_verbatim_locality

      # A spatial representation in well known text
      attr_accessor :wkt

      # Integer in Meters
      #   !! defaults to 100m
      attr_accessor :radius

      # @return [Hash, nil]
      #  in geo_json format (no Feature ...) ?!
      attr_accessor :geo_json

      # @return [Array (Symbols)]
      #   values are ATTRIBUTES that should be wildcarded
      attr_accessor :collecting_event_wildcards

      # DONE: singularize and handle array or single
      # @return [Array]
      attr_accessor :otu_id

      # DONE: singularize and handle array or single
      # @return [Array]
      attr_accessor :collector_id

      # @return [Boolean]
      # @param collector_id_or [String]
      #   'true' - all ids treated as "or"
      #   'false', nil - all ids treated as "and"
      attr_accessor :collector_id_or

      # @param collection_objects [String, nil]
      #   legal values are 'true', 'false'
      #   `true` - match only CollectingEvents with associated CollectionObjects
      #   `false` - match only CollectingEvents without associated CollectionObjects
      # @return collection_objects [Boolean, nil]
      #
      #  whether the CollectingEvent has associated CollectionObjects
      attr_accessor :collection_objects

      # @return Array
      # @param collection_object_id [Array, Integer, String]
      #    all collecting events matching collection objects
      attr_accessor :collection_object_id

      # @return [True, False, nil]
      #   true - index is built
      #   false - index is not built
      #   nil - not applied
      attr_accessor :depictions

      # @return [True, False, nil]
      #   true - georeferences
      #   false - not georeferenced
      #   nil - not applied
      attr_accessor :georeferences

      # @return [True, False, nil]
      #   true - has geographic_area present
      #   false - without geographic_area
      #   nil - not applied
      attr_accessor :geographic_area

      # See /lib/queries/otu/filter.rb
      attr_accessor :geographic_area_id
      attr_accessor :geographic_area_mode

      def initialize(params)
        @collecting_event_id = params[:collecting_event_id]
        @collecting_event_wildcards = params[:collecting_event_wildcards]
        @collection_object_id = params[:collection_object_id]
        @collection_objects = boolean_param(params, :collection_objects )
        @collector_id = params[:collector_id]
        @collector_id_or = boolean_param(params, :collector_id_or )
        @depictions = boolean_param(params, :depictions)
        @geo_json = params[:geo_json]
        @geographic_area = boolean_param(params, :geographic_area)
        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @georeferences = boolean_param(params, :georeferences)
        @in_labels = params[:in_labels]
        @in_verbatim_locality = params[:in_verbatim_locality]
        @md5_verbatim_label = params[:md5_verbatim_label]&.to_s&.downcase == 'true'
        @otu_id = params[:otu_id].presence
        @radius = params[:radius].presence || 100
        @wkt = params[:wkt]

        set_attributes(params)

        set_tags_params(params)
        set_dates(params)
        set_data_attributes_params(params)
        set_notes_params(params)
        super
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      def collector_id
        [@collector_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def collecting_event_wildcards
        [@collecting_event_wildcards].flatten.compact.uniq.map(&:to_sym)
      end

      def attribute_clauses
        c = []
        ATTRIBUTES.each do |a|
          if v = send(a)
            if v.present?
              if collecting_event_wildcards.include?(a)
                c.push Arel::Nodes::NamedFunction.new('CAST', [table[a].as('TEXT')]).matches('%' + v.to_s + '%')
              else
                c.push table[a].eq(v)
              end
            end
          end
        end
        c
      end

      def geographic_area_facet
        return nil if geographic_area.nil?
        if geographic_area
          ::CollectingEvent.where.not(geographic_area_id: null).distinct
        else
          ::CollectingEvent.where(geographic_area_id: null).distinct
        end
      end

      def geographic_area_id_facet
        return nil if geographic_area_id.empty?

        a = nil

        case geographic_area_mode
        when nil, true # exact and spatial start the same
          a = ::GeographicArea.where(id: geographic_area_id)
        when false # descendants
          a = ::GeographicArea.descendants_of_any(geographic_area_id)
        end

        b = nil
        case geographic_area_mode
        when nil, false # exact, descendants
          return ::CollectingEvent.where(geographic_area: a)
        when true # spatial
          i = ::GeographicItem.joins(:geographic_areas).where(geographic_areas: a) # .unscope
          wkt_shape = ::GeographicItem.st_union(i).to_a.first['collection'].to_s
          return from_wkt(wkt_shape)
        end
      end

      def depictions_facet
        return nil if depictions.nil?

        if depictions
          ::CollectingEvent.joins(:depictions).distinct
        else
          ::CollectingEvent.left_outer_joins(:depictions)
            .where(depictions: {id: nil})
            .distinct
        end
      end

      def georeferences_facet
        return nil if georeferences.nil?

        if georeferences
          ::CollectingEvent.joins(:georeferences).distinct
        else
          ::CollectingEvent.left_outer_joins(:georeferences)
            .where(georeferences: {id: nil})
            .distinct
        end
      end

      # @return Scope
      def collection_objects_facet
        return nil if collection_objects.nil?
        subquery = ::CollectionObject.where(::CollectionObject.arel_table[:collecting_event_id].eq(::CollectingEvent.arel_table[:id])).arel.exists
        ::CollectingEvent.where(collection_objects ? subquery : subquery.not)
      end

      # TODO: dry with Source, TaxonName, etc.
      def collector_id_facet
        return nil if collector_id.empty?
        o = table
        r = ::Role.arel_table

        a = o.alias('a_')
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
        b = b.having(a['id'].count.eq(collector_id.length)) unless collector_id_or
        b = b.as('col_z_')

        ::CollectingEvent.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      def wkt_facet
        return nil if wkt.blank?
        from_wkt(wkt)
      end

      # TODO: check, this should be simplifiable.
      def from_wkt(wkt_shape)
        a = RGeo::WKRep::WKTParser.new(Gis::FACTORY, support_wkt12: true)
        b = a.parse(wkt_shape)
        spatial_query(b.geometry_type.to_s, wkt_shape)
      end

      # Shape is a Hash in GeoJSON format
      def geo_json_facet
        return nil if geo_json.nil?
        if a = RGeo::GeoJSON.decode(geo_json)
          return spatial_query(a.geometry_type.to_s, a.to_s)
        else
          return nil
        end
      end

      def spatial_query(geometry_type, wkt)
        case geometry_type
        when 'Point'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(wkt, radius )) # !! TODO: radius is not defined
        when 'Polygon', 'MultiPolygon'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.contained_by_wkt_sql(wkt))
        else
          nil
        end
      end

      def any_label_facet
        return nil if in_labels.blank?
        t = "%#{in_labels}%"
        table[:verbatim_label].matches(t).or(table[:print_label].matches(t)).or(table[:document_label].matches(t))
      end

      def verbatim_label_md5_facet
        return nil unless md5_verbatim_label && in_labels.present?
        md5 = ::Utilities::Strings.generate_md5(in_labels)

        table[:md5_of_verbatim_label].eq(md5)
      end

      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        table[:id].eq_any(collecting_event_id)
      end

      def otu_id_facet
        return nil if otu_id.empty?
        ::CollectingEvent.joins(:otus).where(otus: {id: otu_id})
      end

      def matching_collection_object_id
        return nil if collection_object_id.empty?
        ::CollectingEvent.joins(:collection_objects).where(collection_objects: {id: collection_object_id})
      end

      def verbatim_locality_facet
        return nil if in_verbatim_locality.blank?
        t = "%#{in_verbatim_locality}%"
        table[:verbatim_locality].matches(t)
      end

      # @return [Array]
      def and_clauses
        clauses = attribute_clauses
        clauses += [
          between_date_range,
          any_label_facet,
          collecting_event_id_facet,
          verbatim_label_md5_facet,
          verbatim_locality_facet,
        ]
        clauses
      end

      def merge_clauses
        [
          source_query_facet,
          collection_object_query_facet,

          collection_objects_facet,
          collector_id_facet,
          depictions_facet,
          geo_json_facet,
          geographic_area_facet,
          geographic_area_id_facet,
          georeferences_facet,
          matching_collection_object_id,
          otu_id_facet,
          wkt_facet,
        ]
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_ce AS (' + collection_object_query.all.to_sql + ') ' +
          ::CollectingEvent
          .joins(:collection_objects)
          .joins('JOIN query_co_ce as query_co_ce1 on collection_objects.id = query_co_ce1.id')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events')
      end

    end
  end
end
