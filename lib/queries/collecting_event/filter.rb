module Queries
  module CollectingEvent
    class Filter < Query::Filter
      include Queries::Helpers

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes
      include Queries::Concerns::DateRanges
      include Queries::Concerns::Users
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Identifiers

   # @params params ActionController::Parameters
      # @return ActionController::Parameters
      def self.base_params(params)
        params.permit(
          Queries::CollectingEvent::Filter::ATTRIBUTES,
          :collection_objects,
          :collector_id,
          :collector_ids_or,
          :data_attribute_exact_value,  # DataAttributes concern
          :data_attributes,             # DataAttributes concern
          :depictions,
          :determiner_name_regex,
          :end_date,   # used in date range
          :geo_json,
          :geographic_area_id,
          :geographic_area_mode,
          :georeferences,
          :geographic_area,
          :identifier,
          :identifier_end,
          :identifier_exact,
          :identifier_start,
          :identifiers,
          :in_labels,
          :in_verbatim_locality,
          :match_identifiers,
          :match_identifiers_delimiter,
          :match_identifiers_type,
          :md5_verbatim_label,
          :otu_id,
          :partial_overlap_dates,
          :radius,
          :recent,
          :start_date, # used in date range
          :user_date_end,
          :user_date_start,
          :user_target,
          :user_id,
          :wkt,
          collection_object_id: [],
          collecting_event_wildcards: [],
          collector_id: [],
          geographic_area_id: [],
          keyword_id_and: [],
          keyword_id_or: [],
          otu_id: [],
          data_attribute_predicate_id: [], # DataAttributes concern
          data_attribute_value: [],        # DataAttributes concern
        )
      end

      # @params params ActionController::Parameters
      def self.permit(params)
        deep_permit(:collecting_event, params)
      end

      # TODO: likely move to model (replicated in Source too)
      # Params exists for all CollectingEvent attributes except these
      # collecting_event_id is excluded because we handle it specially in conjunction with `geographic_area_mode``
      ATTRIBUTES = (::CollectingEvent.column_names - %w{project_id created_by_id updated_by_id created_at updated_at geographic_area_id})

      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      PARAMS = %w{
        collecting_event_wildcards
        collector_id
        collector_ids_or
        end_date
        geo_json
        geographic_area_id
        geographic_area_mode
        in_labels
        in_verbatim_locality
        md5_verbatim_label
        partial_overlap_dates
        radius
        start_date
        wkt
      }.freeze

      # @param collecting_event_id [ Array, Integer, nil]
      #   One or more collecting_event_ids
      attr_accessor :collecting_event_id

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
        @collecting_event_wildcards = params[:collecting_event_wildcards] || []
        @collector_id = params[:collector_id]
        @collector_ids_or = boolean_param(params, :collector_ids_or )
        @collection_objects = boolean_param(params, :collection_objects )
        @collection_object_id = params[:collection_object_id]
        @depictions = boolean_param(params, :depictions)
        @georeferences = boolean_param(params, :georeferences)
        @geographic_area = boolean_param(params, :geographic_area)
        @geo_json = params[:geo_json]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @geographic_area_id = params[:geographic_area_id]
        @in_labels = params[:in_labels]
        @in_verbatim_locality = params[:in_verbatim_locality]
        @md5_verbatim_label = params[:md5_verbatim_label]&.to_s&.downcase == 'true'
        @otu_id = params[:otu_id].presence || []
        @radius = params[:radius].presence || 100
        @recent = params[:recent].blank? ? nil : params[:recent].to_i
        @wkt = params[:wkt]

        @collecting_event_id = params[:collecting_event_id]

        set_identifier(params)
        set_tags_params(params)
        set_attributes(params)
        set_dates(params)
        set_user_dates(params)
        set_data_attributes_params(params)
        set_notes_params(params)
        super
      end

      def set_attributes(params)
        ATTRIBUTES.each do |a|
          send("#{a}=", params[a.to_sym])
        end
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

      def attribute_clauses
        c = []
        ATTRIBUTES.each do |a|
          if v = send(a)
            if v.present?
              if collecting_event_wildcards.include?(a)
                c.push Arel::Nodes::NamedFunction.new('CAST', [table[a.to_sym].as('TEXT')]).matches('%' + v.to_s + '%')
              else
                c.push table[a.to_sym].eq(v)
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
      def collector_ids_facet
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
        b = b.having(a['id'].count.eq(collector_id.length)) unless collector_ids_or
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

      def matching_any_label
        return nil if in_labels.blank?
        t = "%#{in_labels}%"
        table[:verbatim_label].matches(t).or(table[:print_label].matches(t)).or(table[:document_label].matches(t))
      end

      def matching_verbatim_label_md5
        return nil unless md5_verbatim_label && in_labels.present?
        md5 = ::Utilities::Strings.generate_md5(in_labels)

        table[:md5_of_verbatim_label].eq(md5)
      end

      def matching_collecting_event_id
        return nil if collecting_event_id.empty?
        table[:id].eq_any(collecting_event_id)
      end

      def matching_otu_ids
        return nil if otu_id.empty?
        ::CollectingEvent.joins(:otus).where(otus: {id: otu_id})
      end

      def matching_collection_object_id
        return nil if collection_object_id.empty?
        ::CollectingEvent.joins(:collection_objects).where(collection_objects: {id: collection_object_id})
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
          matching_collecting_event_id,
          between_date_range,
          matching_verbatim_label_md5,
          matching_any_label,
          matching_verbatim_locality,
        ].compact!

        clauses
      end

      def base_merge_clauses
        clauses = [
          collection_object_query_facet,
          geographic_area_id_facet,
          collection_objects_facet,
          collector_ids_facet,
          created_updated_facet,
          data_attribute_predicate_facet,
          data_attribute_value_facet,
          data_attributes_facet,
          geographic_area_facet,
          depictions_facet,
          georeferences_facet,
          geo_json_facet,
          identifier_between_facet,
          identifier_facet,       # See Queries::Concerns::Identifiers
          identifier_namespace_facet,
          identifiers_facet,      # See Queries::Concerns::Identifiers
          match_identifiers_facet,
          keyword_id_facet,
          matching_otu_ids,
          matching_collection_object_id,
          note_text_facet,        # See Queries::Concerns::Notes
          notes_facet,            # See Queries::Concerns::Notes
          wkt_facet,
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

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_ce AS (' + collection_object_query.all.to_sql + ') ' +
          ::CollectingEvent
          .joins(:collection_objects)
          .joins('JOIN query_co_ce as query_co_ce1 on collection_objects.collecting_event_id = query_co_ce1.id')
          .to_sql

        ::CollectingEvent.from('(' + s + ') as collecting_events')
      end

    end
  end
end
