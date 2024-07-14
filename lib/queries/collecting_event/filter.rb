module Queries
  module CollectingEvent
    class Filter < Query::Filter

      # Params exists for all CollectingEvent attributes except these.
      # geographic_area_id is excluded because we handle it specially in conjunction with `geographic_area_mode``
      # Definition must preceed include.
      ATTRIBUTES = (::CollectingEvent.core_attributes - %w{geographic_area_id} + %w(cached_level0_geographic_name cached_level1_geographic_name cached_level2_geographic_name)).map(&:to_sym).freeze

      include Queries::Concerns::Attributes
      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::DateRanges
      include Queries::Concerns::Depictions
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
        :collector_id_or,
        :collecting_event_id,
        :determiner_name_regex,
        :gazetteer_ids,
        :geo_json,
        :geographic_area,
        :geographic_area_id,
        :geographic_area_mode,
        :georeferences,
        :in_labels,
        :md5_verbatim_label,
        :radius,
        :use_max,
        :use_min,
        :wkt,
        collecting_event_id: [],
        collector_id: [],
        gazetteer_ids: [],
        geographic_area_id: [],
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
      # @param collector_id_or [String]
      #   `false`, nil - treat the ids in collector_id as "or"
      #   'true' - treat the ids in collector_id as "and" (only CollectingEvent with all and only all of collector_id will match)
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

      # @param gazetteer_ids [Array, Integer, String]
      # @return [Array]
      attr_accessor :gazetteer_ids

      # @return [String, nil]
      #   the maximum number of CollectionObjects linked to CollectingEvent
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
        @collector_id_or = boolean_param(params, :collector_id_or )
        @gazetteer_ids = params[:gazetteer_ids]
        @geo_json = params[:geo_json]
        @geographic_area = boolean_param(params, :geographic_area)
        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @georeferences = boolean_param(params, :georeferences)
        @in_labels = params[:in_labels]
        @md5_verbatim_label = params[:md5_verbatim_label]&.to_s&.downcase == 'true'
        @otu_id = params[:otu_id].presence
        @radius = params[:radius].presence || 100.0
        @use_max = params[:use_max]
        @use_min = params[:use_min]
        @wkt = params[:wkt]

        set_attributes_params(params)
        set_citations_params(params)
        set_data_attributes_params(params)
        set_date_params(params)
        set_depiction_params(params)
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

      def gazetteer_ids
        [@gazetteer_ids].flatten.compact
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

      def use_facet
        return nil if (use_min.blank? && use_max.blank?)
        min_max = [use_min&.to_i, use_max&.to_i ].compact

        q = ::CollectingEvent.joins(:collection_objects)
          .select('collecting_events.*, COUNT(collection_objects.collecting_event_id)')
          .group('collecting_events.id')
          .having("COUNT(collecting_event_id) >= #{min_max[0]}")

        # Untested
        q = q.having("COUNT(collecting_event_id) <= #{min_max[1]}") if min_max[1]

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

      def geographic_area_id_facet
        return nil if geographic_area_id.empty?

        a = nil

        case geographic_area_mode
        when nil, true # exact and spatial start the same
          a = ::GeographicArea.where(id: geographic_area_id)
        when false # descendants
          a = ::GeographicArea.descendants_of_any(geographic_area_id)
        end

        case geographic_area_mode
        when nil, false # exact, descendants
          return ::CollectingEvent.where(geographic_area: a)
        when true # spatial
          i = ::GeographicItem.joins(:geographic_areas).where(geographic_areas: a) # .unscope
          wkt_shape = ::GeographicItem.st_union(i).to_a.first['st_union'].to_s
          return from_wkt(wkt_shape)
        end
      end

      def gazetteer_ids_facet
        return nil if gazetteer_ids.empty?

        a = ::Gazetteer.where(id: gazetteer_ids)

        i = ::GeographicItem.joins(:gazetteer).where(gazetteer: a)
        wkt_shape = ::GeographicItem.st_union(i).to_a.first['st_union'].to_s

        from_wkt(wkt_shape)
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

      # TODO: Spatial concern?
      def spatial_query(geometry_type, wkt)
        case geometry_type
        when 'Point'
          ::CollectingEvent
            .joins(:geographic_items)
            .where(::GeographicItem.within_radius_of_wkt_sql(wkt, radius))
        when 'Polygon', 'MultiPolygon'
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
        ::CollectingEvent.joins(:otus).where(otus: {id: otu_id}).distinct
      end

      def matching_collection_object_id
        return nil if collection_object_id.empty?
        ::CollectingEvent.joins(:collection_objects).where(collection_objects: {id: collection_object_id}).distinct
      end

      def collectors_facet
        return nil if collectors.nil?
        if collectors
          ::CollectingEvent.joins(:collectors)
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
        s = 'WITH query_otu_ces AS (' + otu_query.all.to_sql + ') ' +
          ::CollectingEvent.joins(:otus)
          .joins('JOIN query_otu_ces as query_otu_ces1 on query_otu_ces1.id = otus.id')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events').distinct
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

      def dwc_occurrence_query_facet
        return nil if dwc_occurrence_query.nil?

        s = ::CollectingEvent
          .with(query_dwc_ce: dwc_occurrence_query.select(:dwc_occurrence_object_id, :dwc_occurrence_object_type, :id))
          .joins('JOIN collection object co co.collecting_event_id = collecting_events.id')
          .joins("JOIN dwc_occurrences do on do.dwc_occurrence_object_type = 'CollectionObject' and do.dwc_occurrence_object_id = co.id")
          .joins('JOIN query_dwc_ce as query_dwc_ce1 on query_dwc_ce1.id = dwc_occurrences.id')
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
          dwc_occurrence_query_facet,
          otu_query_facet,
          taxon_name_query_facet,

          collectors_facet,
          collection_objects_facet,
          collector_id_facet,
          geo_json_facet,
          gazetteer_ids_facet,
          geographic_area_facet,
          geographic_area_id_facet,
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
