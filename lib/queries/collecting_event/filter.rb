module Queries
  module CollectingEvent
    class Filter < Query::Filter

      # Params exists for all CollectingEvent attributes except these.
      # geo_shape_id is excluded because we handle it specially in conjunction with `geo_mode`
      # Definition must preceed include.
      ATTRIBUTES = (::CollectingEvent.core_attributes - %w{geo_shape_id geo_shape_type} + %w(cached_level0_geographic_name cached_level1_geographic_name cached_level2_geographic_name)).map(&:to_sym).freeze

      include Queries::Concerns::Attributes
      include Queries::Concerns::Citations
      include Queries::Concerns::Confidences
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::DateRanges
      include Queries::Concerns::Depictions
      include Queries::Concerns::Geo
      include Queries::Concerns::Notes
      include Queries::Concerns::Protocols
      include Queries::Concerns::Tags
      include Queries::Helpers

      # This list of params are those that only occur
      # in this CollectingEvent filter. For those
      # that overlap other filters place in PARAMS.
      #
      # Used to define a base collecting query for CollectionObject
      # filters scope, this is still used in CollectionObject query.
      # This is "necessary" so that we can use CollectingEvent
      # referencing facets in the CollectionObject filter for
      # convienience.
      #
      BASE_PARAMS = [
        *Queries::Concerns::Attributes.params,
        *ATTRIBUTES,
        :collectors,
        :collecting_event_object_id,
        :collection_objects,
        :collector_id,
        :collector_id_all,
        :collecting_event_id,
        :determiner_name_regex,
        :geo_json,
        :geographic_area,
        :geo_mode,
        :geo_shape_id,
        :geo_shape_type,
        :georeferences,
        :in_labels,
        :md5_verbatim_label,
        :radius,
        :use_max,
        :use_min,
        :wkt,
        :wkt_geometry_type,
        collecting_event_id: [],
        collector_id: [],
        geo_shape_id: [],
        geo_shape_type: []
      ].inject([{}]){|ary, k| k.is_a?(Hash) ? ary.last.merge!(k) : ary.unshift(k); ary}.freeze

      PARAMS = [
        *BASE_PARAMS,
        :otu_id,
        :collection_object_id,
        collection_object_id: [],
        otu_id: [],
      ].inject([{}]){|ary, k| k.is_a?(Hash) ? ary.last.merge!(k) : ary.unshift(k); ary}.freeze

      def self.base_params
        a = BASE_PARAMS.dup
        b = a.pop.keys
        (a + b).uniq
      end

      # @return [Boolean, nil]
      #  true - A collector role exists
      #  false - A collector role exists
      #  nil - not applied
      attr_accessor :collectors

      # @param collecting_event_id [ Array, Integer, nil]
      #   One or more collecting_event_id
      attr_accessor :collecting_event_id

      # Wildcard wrapped matching any label
      attr_accessor :in_labels

      # If true then in_labels checks only the MD5
      attr_accessor :md5_verbatim_label

      # A spatial representation in well known text
      attr_accessor :wkt

      # Geometry type (Point, MultiPolygon, etc.) of `wkt`
      attr_accessor :wkt_geometry_type

      # Integer in Meters
      #   !! defaults to 100m
      attr_accessor :radius

      # @return [Hash, nil]
      #  in geo_json format (no Feature ...) ?!
      attr_accessor :geo_json

      # DONE: singularize and handle array or single
      # @return [Array]
      attr_accessor :otu_id

      # DONE: singularize and handle array or single
      # @return [Array]
      attr_accessor :collector_id

      # @return [Boolean]
      # @param collector_id_all [String]
      #   `false`, nil - treat the ids in collector_id as "or"
      #   'true' - treat the ids in collector_id as "and" (only CollectingEvent with all and only all of collector_id will match)
      attr_accessor :collector_id_all

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
      #   true - georeferences
      #   false - not georeferenced
      #   nil - not applied
      attr_accessor :georeferences

      # @return [True, False, nil]
      #   true - has geographic_area present
      #   false - without geographic_area
      #   nil - not applied
      attr_accessor :geographic_area

      # @return [String, nil]
      #   the maximum number of CollectionObjects linked to CollectingEvent
      #   must be > use_min, defaults to use_min if blank and use_min
      attr_accessor :use_max

      # @return [String, nil]
      #   the minimum number of CollectionObjects linked to CollectingEvent
      attr_accessor :use_min

      def initialize(query_params)
        super

        @collectors = boolean_param(params, :collectors )
        @collecting_event_id = params[:collecting_event_id]
        @collection_object_id = params[:collection_object_id]
        @collection_objects = boolean_param(params, :collection_objects )
        @collector_id = params[:collector_id]
        @collector_id_all = boolean_param(params, :collector_id_all )
        @geo_json = params[:geo_json]
        @geographic_area = boolean_param(params, :geographic_area)
        @georeferences = boolean_param(params, :georeferences)
        @in_labels = params[:in_labels]
        @md5_verbatim_label = params[:md5_verbatim_label]&.to_s&.downcase == 'true'
        @otu_id = params[:otu_id].presence
        @radius = params[:radius].presence || 100.0
        @use_max = params[:use_max]
        @use_min = params[:use_min]
        @wkt = params[:wkt]
        @wkt_geometry_type = params[:wkt_geometry_type]

        set_confidences_params(params)
        set_attributes_params(params)
        set_citations_params(params)
        set_data_attributes_params(params)
        set_date_params(params)
        set_depiction_params(params)
        set_geo_params(params)
        set_notes_params(params)
        set_protocols_params(params)
        set_tags_params(params)
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def collector_id
        [@collector_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def use_min
        return nil if @use_min.blank? && @use_max.blank?
        @use_min&.to_i || 0
      end

      def use_max
        return nil if @use_min.blank? && @use_max.blank?
        @use_max&.to_i || use_min
      end

      def use_facet
        return nil if (use_min.blank? && use_max.blank?)
        return ::CollectingEvent.none if use_min > use_max

        q = ::CollectingEvent.left_joins(:collection_objects, :field_occurrences)
          .group(collecting_events: [:id])

        if use_min == use_max
          if use_min == 0
            q = ::CollectingEvent.where.missing(:collection_objects, :field_occurrences)
          else
            q = q.having('COUNT(collection_objects.id) + COUNT(field_occurrences.id) = ? ', use_min)
          end
        else
          q = q.having('COUNT(collection_objects.id) + COUNT(field_occurrences.id) BETWEEN ? AND ?', use_min, use_max)
        end

        q = q.select(collecting_events: [:id])
        ::CollectingEvent.from('(' + q.to_sql + ') as collecting_events').distinct
      end

      def geographic_area_facet
        return nil if geographic_area.nil?
        if geographic_area
          ::CollectingEvent.where.not(geographic_area_id: nil).distinct
        else
          ::CollectingEvent.where(geographic_area_id: nil).distinct
        end
      end

      def collecting_event_geo_facet
        return nil if geo_shape_id.empty? || geo_shape_type.empty? ||
          # TODO: this should raise an error(?)
          geo_shape_id.length != geo_shape_type.length
        return ::CollectingEvent.none if roll_call

        geographic_area_shapes, gazetteer_shapes = shapes_for_geo_mode

        a = collecting_event_geo_facet_by_type(
          'GeographicArea', geographic_area_shapes
        )

        b = collecting_event_geo_facet_by_type(
          'Gazetteer', gazetteer_shapes
        )

        if geo_mode != true # exact or descendants
          return referenced_klass_union([a,b])
        end

        # Spatial.
        i = ::Queries.union(::GeographicItem, [a,b])

        ::CollectingEvent
          .joins(:geographic_items)
          .where(::GeographicItem.covered_by_geographic_items_sql(i))
      end

      def collecting_event_geo_facet_by_type(shape_string, shape_ids)
        b = nil

        case geo_mode
        when nil, false # exact, descendants
          return nil if shape_string == 'Gazetteer'
          b = ::CollectingEvent.where(geographic_area: shape_ids)
        when true # spatial
          m = shape_string.tableize
          b = ::GeographicItem.joins(m.to_sym).where(m => shape_ids)
        end

        b
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
        f = c[:person_id].in(collector_id)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(collector_id.length)) if collector_id_all
        b = b.as('col_z_')

        ::CollectingEvent.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      def wkt_facet
        return nil if wkt.blank?
        return ::CollectingEvent.none if roll_call

        from_wkt(wkt, wkt_geometry_type)
      end

      # TODO: check, this should be simplifiable.
      def from_wkt(wkt_shape, geometry_type = nil)
        if (geometry_type.nil?)
          a = RGeo::WKRep::WKTParser.new(Gis::FACTORY, support_wkt12: true)
          b = a.parse(wkt_shape)
          geometry_type = b.geometry_type.to_s
        end
        spatial_query(geometry_type, wkt_shape)
      end

      # Shape is a Hash in GeoJSON format
      def geo_json_facet
        return nil if geo_json.nil?
        return ::CollectingEvent.none if roll_call

        if a = RGeo::GeoJSON.decode(geo_json)
          return spatial_query(a.geometry_type.to_s, a.to_s)
        else
          return nil
        end
      end

      # TODO: Spatial concern?
      def spatial_query(geometry_type, wkt)
        case geometry_type
        when 'Point'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(wkt, radius))
        when 'Polygon', 'MultiPolygon', 'GeometryCollection'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.covered_by_wkt_sql(wkt))
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
        table[:id].in(collecting_event_id)
      end

      def otu_id_facet
        return nil if otu_id.empty?
        a = ::CollectingEvent.joins(:collection_object_otus).where(otus: {id: otu_id})
        b = ::CollectingEvent.joins(:field_occurrence_otus).where(otus: {id: otu_id})
        ::Queries.union(::CollectingEvent, [a,b]).distinct
      end

      def matching_collection_object_id
        return nil if collection_object_id.empty?
        ::CollectingEvent.joins(:collection_objects).where(collection_objects: {id: collection_object_id}).distinct
      end

      def collectors_facet
        return nil if collectors.nil?
        if collectors
          ::CollectingEvent.joins(:collectors).distinct
        else
          ::CollectingEvent.where.missing(:collectors)
        end
      end

      def biological_association_query_facet
        return nil if biological_association_query.nil?
        s = 'WITH query_ba_ces AS (' + biological_association_query.all.to_sql + ') ' +
          ::CollectingEvent.joins(:collection_objects)
          .joins("LEFT JOIN query_ba_ces as query_ba_ces1 on collection_objects.id = query_ba_ces1.biological_association_subject_id AND query_ba_ces1.biological_association_subject_type = 'CollectionObject'")
          .joins("LEFT JOIN query_ba_ces as query_ba_ces2 on collection_objects.id = query_ba_ces2.biological_association_object_id AND query_ba_ces2.biological_association_object_type = 'CollectionObject'")
          .where('(query_ba_ces1.id) IS NOT NULL OR (query_ba_ces2.id IS NOT NULL)')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events').distinct
      end

      def otu_query_facet
        return nil if otu_query.nil?

        a = ::CollectingEvent.with(otu_scope: otu_query.all)
          .joins(collection_objects: [:taxon_determinations])
          .joins('JOIN otu_scope on otu_scope.id = taxon_determinations.otu_id')
          .where(taxon_determinations: {position: 1})

        b = ::CollectingEvent.with(otu_scope: otu_query.all)
          .joins(field_occurrences: [:taxon_determinations])
          .joins('JOIN otu_scope on otu_scope.id = taxon_determinations.otu_id')
          .where(taxon_determinations: {position: 1})

        ::Queries.union(::CollectingEvent, [a,b])
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_ce AS (' + collection_object_query.all.to_sql + ') ' +
          ::CollectingEvent
          .joins(:collection_objects)
          .joins('JOIN query_co_ce as query_co_ce1 on collection_objects.id = query_co_ce1.id')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events').distinct
      end

      def field_occurrence_query_facet
        return nil if field_occurrence_query.nil?
        s = 'WITH query_fo_ce AS (' + field_occurrence_query.all.to_sql + ') ' +
          ::CollectingEvent
          .joins(:field_occurrences)
          .joins('JOIN query_fo_ce as query_fo_ce1 on field_occurrences.id = query_fo_ce1.id')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events').distinct
      end

      def dwc_occurrence_query_facet
        return nil if dwc_occurrence_query.nil?

        s = ::CollectingEvent
          .with(query_dwc_ce: dwc_occurrence_query.all.select(:dwc_occurrence_object_id, :dwc_occurrence_object_type, :id))
          .joins('JOIN collection_objects co on co.collecting_event_id = collecting_events.id')
          .joins("JOIN dwc_occurrences dwo on dwo.dwc_occurrence_object_type = 'CollectionObject' and dwo.dwc_occurrence_object_id = co.id")
          .joins('JOIN query_dwc_ce as query_dwc_ce1 on query_dwc_ce1.id = dwo.id')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events').distinct
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        s = 'WITH query_tn_ce AS (' + taxon_name_query.all.to_sql + ') ' +
          ::CollectingEvent
          .joins(collection_objects: [:otus])
          .joins('JOIN query_tn_ce as query_tn_ce1 on otus.taxon_name_id = query_tn_ce1.id')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events').distinct
      end

      def housekeeping_extensions
        [
          housekeeping_extension_query(target: ::DataAttribute, joins: [:data_attributes]),
          housekeeping_extension_query(target: ::Georeference, joins: [:georeferences]),
          housekeeping_extension_query(target: ::Note, joins: [:notes]),
          housekeeping_extension_query(target: ::Role, joins: [:roles]),
        ]
      end

      # @return [Array]
      def and_clauses
        [
          between_date_range_facet,
          any_label_facet,
          collecting_event_id_facet,
          verbatim_label_md5_facet,
        ]
      end

      def merge_clauses
        [
          biological_association_query_facet,
          collection_object_query_facet,
          field_occurrence_query_facet,
          dwc_occurrence_query_facet,
          otu_query_facet,
          taxon_name_query_facet,

          collecting_event_geo_facet,
          collectors_facet,
          collection_objects_facet,
          collector_id_facet,
          geo_json_facet,
          geographic_area_facet,
          georeferences_facet,
          matching_collection_object_id,
          otu_id_facet,
          use_facet,
          wkt_facet,
        ]
      end

    end
  end
end
