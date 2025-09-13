module Queries
  module BiologicalAssociation

    class Filter < Query::Filter
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations
      include Queries::Concerns::Confidences
      include Queries::Concerns::Depictions
      include Queries::Concerns::Geo

      PARAMS = [
        :biological_association_id,
        :biological_associations_graph_id,
        :biological_relationship_id,
        :collecting_event_id,
        :collection_object_id,
        :descendants,
        :exclude_taxon_name_relationship,
        :field_occurrence_id,
        :geo_json,
        :geo_mode,
        :geo_shape_id,
        :geo_shape_type,
        :geo_collecting_event_geographic_area,
        :object_biological_property_id,
        :object_object_global_id,
        :object_taxon_name_id,
        :object_type,
        :otu_id,
        :radius,
        :subject_biological_property_id,
        :subject_object_global_id,
        :subject_taxon_name_id,
        :subject_type,
        :taxon_name_id,
        :taxon_name_id_mode,
        :wkt,
        :biological_association_object_id,
        :biological_association_object_type,
        :biological_association_subject_id,
        :biological_association_subject_type,

        any_global_id: [],
        biological_association_id: [],
        biological_associations_graph_id: [],
        biological_relationship_id: [],
        collecting_event_id: [],
        collection_object_id: [],
        field_occurrence_id: [],
        geo_shape_id: [],
        geo_shape_type: [],
        object_biological_property_id: [],
        object_object_global_id: [],
        object_taxon_name_id: [],
        otu_id: [],
        subject_biological_property_id: [],
        subject_object_global_id: [],
        subject_taxon_name_id: [],
        taxon_name_id: [],
        biological_association_object_id: [],
        biological_association_object_type: [],
        biological_association_subject_id: [],
        biological_association_subject_type: []
      ].freeze

      API_PARAM_EXCLUSIONS = [
        :any_global_id
      ]

      # @return Boolean, nil
      #  if true then return relationships *excluding*
      # those listed in biological_relationship_id
      attr_accessor :exclude_taxon_name_relationship

      # @param collecting_event_id
      # @return Integer
      #   All BiologicalAssociations with CollectionObjects
      # linked to one or more CollectingEvent
      attr_accessor :collecting_event_id

      # @param otu_id
      # @return [Array]
      #   All BiologicalAssociations with OTU (only)
      #  matching subject OR object
      attr_accessor :otu_id

      # @param collection_object_id
      # @return [Array]
      #   All biological relationships with CollectionObject (only)
      #  matching subject OR object
      attr_accessor :collection_object_id

      # @param field_occurrence_id
      # @return [Array]
      #   All biological relationships with FieldOccurrence (only)
      #  matching subject OR object
      attr_accessor :field_occurrence_id

      # @param subject_taxon_name_id
      #   All BiologicalAssociations matching this name or
      # its children.
      # !! TaxonName must be valid!
      attr_accessor :subject_taxon_name_id

      # @param object_taxon_name_id
      #   All BiologicalAssociations matching this name or
      # its children
      # !! TaxonName must be valid!
      attr_accessor :object_taxon_name_id

      # @param taxon_name_id
      # @return [Array]
      #   All BiologicalAssociations matching these names or
      # their children
      attr_accessor :taxon_name_id

      # @return [Boolean, nil]
      attr_accessor :taxon_name_id_mode

      attr_accessor :descendants

      # @param biological_associations_graph_id
      #   All BiologicalAssociations in any of the graphs above
      attr_accessor :biological_associations_graph_id

      # @return [Array]
      #   All BiologicalAssociations with subject having this property
      attr_accessor :subject_biological_property_id

      # @return [Array]
      #   All BiologicalAssociations with object having this property
      attr_accessor :object_biological_property_id

      # @return [Array]
      #   one or more BiologicalAssociation#id
      # @param biological_association_id [Array, Integer]
      attr_accessor :biological_association_id

      # @return [Array]
      #   one or more biological relationship ID
      # See also exclude_taxon_name_relationship
      # @param biological_relationship_id [Array, Integer]
      attr_accessor :biological_relationship_id

      # @return [Array]
      #   a biological relationship graph ID
      # @param biological_associations_graph_id [Array, Integer]
      attr_accessor :biological_associations_graph_id

      # @return [Array]
      attr_accessor :subject_object_global_id

      # @return [Array]
      attr_accessor :object_object_global_id

      # @return [Array]
      attr_accessor :any_global_id

      # See lib/queries/otu/filter.rb
      attr_accessor :wkt
      attr_accessor :geo_json

      # @return [nil, 'Otu', 'CollectionObject']
      #  limit subject to a type
      attr_accessor :subject_type

      # @return [nil, 'Otu', 'CollectionObject']
      #  limit object to a type
      attr_accessor :object_type

      attr_accessor :biological_association_object_id

      attr_accessor :biological_association_object_type

      attr_accessor :biological_association_subject_id

      attr_accessor :biological_association_subject_type

      # Integer in Meters
      #   !! defaults to 100m
      attr_accessor :radius

      def initialize(query_params)
        super

        @any_global_id = params[:any_global_id]
        @biological_association_id = params[:biological_association_id]
        @biological_associations_graph_id = params[:biological_associations_graph_id]
        @biological_relationship_id = params[:biological_relationship_id]
        @collecting_event_id = params[:collecting_event_id]
        @collection_object_id = params[:collection_object_id]
        @field_occurrence_id = params[:field_occurrence_id]
        @descendants = boolean_param(params, :descendants)
        @exclude_taxon_name_relationship = boolean_param(params, :exclude_taxon_name_relationship)
        @geo_shape_type = params[:geo_shape_type]
        @geo_shape_id = integer_param(params, :geo_shape_id)
        @geo_mode = boolean_param(params, :geo_mode)
        @geo_collecting_event_geographic_area = boolean_param(params, :geo_collecting_event_geographic_area)
        @geo_json = params[:geo_json]
        @object_biological_property_id = params[:object_biological_property_id]
        @object_object_global_id = params[:object_object_global_id]
        @object_taxon_name_id = params[:object_taxon_name_id]
        @object_type = params[:object_type]
        @otu_id = params[:otu_id]
        @radius = params[:radius].presence || 100.0
        @subject_biological_property_id = params[:subject_biological_property_id]
        @subject_object_global_id = params[:subject_object_global_id]
        @subject_taxon_name_id = params[:subject_taxon_name_id]
        @subject_type = params[:subject_type]
        @taxon_name_id = params[:taxon_name_id]
        @taxon_name_id_mode = boolean_param(params, :taxon_name_id_mode)
        @wkt = params[:wkt]
        @biological_association_object_id = params[:biological_association_object_id]
        @biological_association_object_type = params[:biological_association_object_type]
        @biological_association_subject_id = params[:biological_association_subject_id]
        @biological_association_subject_type = params[:biological_association_subject_type]

        set_confidences_params(params)
        set_notes_params(params)
        set_tags_params(params)
        set_citations_params(params)
        set_depiction_params(params)
        set_geo_params(params)
      end

      def biological_association_id
        [@biological_association_id].flatten.compact
      end

      def object_biological_property_id
        [@object_biological_property_id].flatten.compact
      end

      def subject_biological_property_id
        [@subject_biological_property_id].flatten.compact
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def subject_taxon_name_id
        [@subject_taxon_name_id].flatten.compact
      end

      def object_taxon_name_id
        [@object_taxon_name_id].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def field_occurrence_id
        [@field_occurrence_id].flatten.compact
      end

      def biological_relationship_id
        [@biological_relationship_id].flatten.compact
      end

      def biological_associations_graph_id
        [@biological_associations_graph_id].flatten.compact
      end

      def subject_object_global_id
        [@subject_object_global_id].flatten.compact
      end

      def object_object_global_id
        [@object_object_global_id].flatten.compact
      end

      def biological_association_object_id
        [@biological_association_object_id].flatten.compact
      end

      def biological_association_object_type
        [@biological_association_object_type].flatten.compact
      end

      def biological_association_subject_id
        [@biological_association_subject_id].flatten.compact
      end

      def biological_association_subject_type
        [@biological_association_subject_type].flatten.compact
      end

      def any_global_id
        [@any_global_id].flatten.compact
      end

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      # Results are also returned from the otu and CO queries on subject/object.
      def from_wkt(wkt_shape)
        a = ::Queries::AssertedDistribution::Filter.new(
          wkt: wkt_shape, project_id:,
          asserted_distribution_object_type: 'BiologicalAssociation'
        )

        ::BiologicalAssociation
          .with(ad: a.all)
          .joins('JOIN ad ON ad.asserted_distribution_object_id = biological_associations.id')
      end

      # Results are also returned from the otu and CO queries on subject/object.
      def geo_json_facet
        return nil if geo_json.blank?
        return ::BiologicalAssociation.none if roll_call

        a = ::Queries::AssertedDistribution::Filter.new(
          geo_json:, project_id:, radius:,
          asserted_distribution_object_type: 'BiologicalAssociation'
        )

        ::BiologicalAssociation
          .with(ad: a.all)
          .joins('JOIN ad ON ad.asserted_distribution_object_id = biological_associations.id')
      end

      # Results are also returned from the otu and CO queries on subject/object.
      def biological_association_geo_facet
        return nil if geo_shape_id.empty? || geo_shape_type.empty? ||
          # TODO: this should raise an error(?)
          geo_shape_id.length != geo_shape_type.length
        return ::BiologicalAssociation.none if roll_call

        geographic_area_shapes, gazetteer_shapes = shapes_for_geo_mode

        a = biological_association_geo_facet_by_type(
          'GeographicArea', geographic_area_shapes
        )

        b = biological_association_geo_facet_by_type(
          'Gazetteer', gazetteer_shapes
        )

        if geo_mode == true # spatial
          i = ::Queries.union(::GeographicItem, [a,b])
          u = ::Queries::GeographicItem.st_union_text(i).to_a.first

          return from_wkt(u['st_astext'])
        end

        referenced_klass_union([a,b])
      end

      def biological_association_geo_facet_by_type(shape_string, shape_ids)
        case geo_mode
        when nil, false # exact, descendants
          ::BiologicalAssociation
            .joins("JOIN asserted_distributions ON asserted_distributions.asserted_distribution_object_id = biological_associations.id AND asserted_distributions.asserted_distribution_object_type = 'BiologicalAssociation'")
            .where(asserted_distributions: {
              asserted_distribution_shape: shape_ids
           })
        when true # spatial
          m = shape_string.tableize
          b = ::GeographicItem.joins(m.to_sym).where(m => shape_ids)
        end
      end

      # Results are also returned from the otu and CO queries on subject/object.
      def biological_associations_graph_geo_facet
        bag_query = ::Queries::BiologicalAssociationsGraph::Filter.new({
          geo_json:,
          geo_shape_id:,
          geo_shape_type:,
          geo_mode:,
          radius:,
          wkt:
        })

        bag_scope = bag_query.all
        return nil if bag_query.only_project?() || bag_scope.nil?

        ::BiologicalAssociation
          .joins(:biological_associations_graphs)
          .where(biological_associations_graphs: {id: bag_scope.select(:id)})
      end

      def subject_matches(object)
        table['biological_association_subject_id'].eq(object.id).and(
          table['biological_association_subject_type'].eq(object.class.base_class.name)
        )
      end

      def object_matches(object)
        table['biological_association_object_id'].eq(object.id).and(
          table['biological_association_object_type'].eq(object.class.base_class.name)
        )
      end

      def biological_association_object_type_facet
        return nil if biological_association_object_type.empty?
        table[:biological_association_object_type].in(biological_association_object_type)
      end

      def biological_association_object_id_facet
        return nil if biological_association_object_id.empty?
        table[:biological_association_object_id].in(biological_association_object_id)
      end

      def biological_association_subject_type_facet
        return nil if biological_association_subject_type.empty?
        table[:biological_association_subject_type].in(biological_association_subject_type)
      end

      def biological_association_subject_id_facet
        return nil if biological_association_subject_id.empty?
        table[:biological_association_subject_id].in(biological_association_subject_id)
      end

      def object_biological_property_id_facet
        return nil if object_biological_property_id.empty?
        ::BiologicalAssociation.joins(:object_biological_relationship_types)
          .where(biological_relationship_types: {biological_property_id: object_biological_property_id })
      end

      def subject_biological_property_id_facet
        return nil if subject_biological_property_id.empty?
        ::BiologicalAssociation.joins(:subject_biological_relationship_types)
          .where(biological_relationship_types: {biological_property_id: subject_biological_property_id })
      end

      def biological_associations_graph_id_facet
        return nil if biological_associations_graph_id.empty?
        ::BiologicalAssociation.joins(:biological_associations_graphs).where(biological_associations_graphs: {id: biological_associations_graph_id})
      end

      def collection_object_params
        h = {}
        [
          :collecting_event_id,
          :collection_object_id,
          :geo_json,
          :geo_mode,
          :geo_shape_id,
          :geo_shape_type,
          :geo_collecting_event_geographic_area,
          :wkt,
        ].each do |p|
          v = send(p)
          h[p] = v if v.present?
        end
        h
      end

      def field_occurrence_params
        h = {}
        [
          :collecting_event_id,
          :field_occurrence_id,
          :geo_json,
          :geo_mode,
          :geo_shape_id,
          :geo_shape_type,
          :wkt,
        ].each do |p|
          v = send(p)
          h[p] = v if v.present?
        end
        h
      end

      def otu_params
        h = {}
        [
          :geo_json,
          :geo_mode,
          :geo_shape_id,
          :geo_shape_type,
          :geo_collecting_event_geographic_area,
          :otu_id,
          :wkt,
        ].each do |p|
          v = send(p)
          h[p] = v if v.present?
        end
        h
      end

      def base_otu_query(opts)
        ::Queries::Otu::Filter.new(opts)
      end

      def base_collection_object_query(opts)
        ::Queries::CollectionObject::Filter.new(opts)
      end

      def base_field_occurrence_query(opts)
        ::Queries::FieldOccurrence::Filter.new(opts)
      end

      def subject_collection_object_query
        p = {}
        s = subject_taxon_name_ids

        if s.empty?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        q = base_collection_object_query(p)
      end

      def object_collection_object_query
        p = {}
        s = object_taxon_name_ids

        if s.empty?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        q = base_collection_object_query(p)
      end

      def subject_field_occurrence_query
        p = {}
        s = subject_taxon_name_ids

        if s.empty?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        q = base_field_occurrence_query(p)
      end

      def object_field_occurrence_query
        p = {}
        s = object_taxon_name_ids

        if s.empty?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        q = base_field_occurrence_query(p)
      end

      def subject_otu_query
        p = {}
        s = subject_taxon_name_ids

        if s.empty?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        base_otu_query(p)
      end

      def object_otu_query
        p = {}
        s = object_taxon_name_ids

        if s.empty?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        base_otu_query(p)
      end

      def subject_scope
        target_scope('subject')
      end

      def object_scope
        target_scope('object')
      end

      def target_scope(target = 'subject')
        a = send((target + '_otu_query').to_sym)
        b = send((target + '_collection_object_query').to_sym)
        c = send((target + '_field_occurrence_query').to_sym)

        a_query, b_query, c_query = nil, nil, nil

        if !a.nil? && !a.only_project?
          a_query = a.all
        end

        if !b.nil? && !b.only_project?
          b_query = b.all
        end

        if !c.nil? && !c.only_project?
          c_query = c.all
        end

        return nil if a_query.nil? && b_query.nil? && c_query.nil?

        d, e, f = nil, nil, nil

        if a_query
          d = ::BiologicalAssociation
            .with(a: a_query)
            .joins("JOIN a ON a.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'Otu'")
        end

        if b_query
          e = ::BiologicalAssociation
            .with(b: b_query)
            .joins("JOIN b ON b.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'CollectionObject'")
        end

        if c_query
          f = ::BiologicalAssociation
            .with(c: c_query)
            .joins("JOIN c ON c.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'FieldOccurrence'")
        end

        referenced_klass_union([d,e,f])
      end

      # Merges results from Otu and CollectionObject filters
      # as the basis for the query
      def subject_object_facet
        o_params = otu_params
        co_params = collection_object_params
        fo_params = field_occurrence_params
        return nil if o_params.empty? && co_params.empty? && fo_params.empty?

        a = o_params.empty? ? nil : base_otu_query(o_params).all
        b = co_params.empty? ? nil : base_collection_object_query(co_params).all
        c = fo_params.empty? ? nil : base_field_occurrence_query(fo_params).all

        subjects = base_queries_to_subject_object(a, b, c, 'subject')
        objects = base_queries_to_subject_object(a, b, c, 'object')

        referenced_klass_union([subjects,objects])
      end

      def taxon_name_id_facet
        return nil if subject_taxon_name_ids.empty? && object_taxon_name_ids.empty?

        a = subject_scope
        b = object_scope

        case taxon_name_id_mode
        when true # and
          referenced_klass_intersection([a,b])
        when false, nil # or
          referenced_klass_union([a,b])
        end
      end

      def base_queries_to_subject_object(
        otu_query, collection_object_query, field_occurrence_query, target
      )
        o = otu_query.nil? ? ::BiologicalAssociation.none :
          ::BiologicalAssociation
            .with(a: otu_query)
            .joins("JOIN a ON a.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'Otu'")

        co = collection_object_query.nil? ? ::BiologicalAssociation.none :
          ::BiologicalAssociation
            .with(b: collection_object_query)
            .joins("JOIN b ON b.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'CollectionObject'")

        fo = field_occurrence_query.nil? ? ::BiologicalAssociation.none :
          ::BiologicalAssociation
            .with(c: field_occurrence_query)
            .joins("JOIN c ON c.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'FieldOccurrence'")

        referenced_klass_union([o,co,fo])
      end

      def subject_object_global_id_facet
        return nil if subject_object_global_id.empty?
        matching_global_id(:subject, subject_object_global_id)
      end

      def object_object_global_id_facet
        return nil if object_object_global_id.empty?
        matching_global_id(:object, object_object_global_id)
      end

      def any_global_id_facet
        return nil if any_global_id.empty?
        a = matching_global_id(:subject, any_global_id)
        b = matching_global_id(:object, any_global_id)
        if a && b
          return a.or(b)
        else
          return a ? a : b
        end
      end

      def biological_relationship_id_facet
        return nil if biological_relationship_id.empty?
        if exclude_taxon_name_relationship
          table[:biological_relationship_id].not_in(biological_relationship_id)
        else
          table[:biological_relationship_id].in(biological_relationship_id)
        end
      end

      def biological_association_id_facet
        return nil if biological_association_id.empty?
        table[:id].in(biological_association_id)
      end

      def object_type_facet
        return nil if object_type.nil?
        table[:biological_association_object_type].eq(object_type)
      end

      def subject_type_facet
        return nil if subject_type.nil?
        table[:biological_association_subject_type].eq(subject_type)
      end

      def collecting_event_query_facet
        return nil if collecting_event_query.nil?

        s = 'WITH query_ce_ba AS (' + collecting_event_query.all.to_sql + ') '

        a = ::BiologicalAssociation
          .joins("JOIN collection_objects co1 on co1.id = biological_associations.biological_association_subject_id AND biological_associations.biological_association_subject_type = 'CollectionObject'")
          .joins('JOIN query_ce_ba as query_ce_ba1 on co1.collecting_event_id = query_ce_ba1.id')

        b = ::BiologicalAssociation
          .joins("JOIN collection_objects co2 on co2.id = biological_associations.biological_association_object_id AND biological_associations.biological_association_object_type = 'CollectionObject'")
          .joins('JOIN query_ce_ba as query_ce_ba2 on co2.collecting_event_id = query_ce_ba2.id')

        s << referenced_klass_union([a,b]).to_sql

        ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      def otu_query_facet
        return nil if otu_query.nil?
        s = 'WITH query_otu_ba AS (' + otu_query.all.to_sql + ') '

        a = ::BiologicalAssociation
          .joins("JOIN query_otu_ba as query_otu_ba1 on biological_associations.biological_association_subject_id = query_otu_ba1.id AND biological_associations.biological_association_subject_type = 'Otu'")

        b = ::BiologicalAssociation
          .joins("JOIN query_otu_ba as query_otu_ba2 on biological_associations.biological_association_object_id = query_otu_ba2.id AND biological_associations.biological_association_object_type = 'Otu'")

        s << referenced_klass_union([a,b]).to_sql
        ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      def asserted_distribution_query_facet
        return nil if asserted_distribution_query.nil?

        ::BiologicalAssociation
          .with(ad: asserted_distribution_query.all)
          .joins("JOIN asserted_distributions ON asserted_distributions.asserted_distribution_object_id = biological_associations.id AND asserted_distributions.asserted_distribution_object_type = 'BiologicalAssociation'").distinct
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_ba AS (' + collection_object_query.all.to_sql + ') '

        a = ::BiologicalAssociation
          .joins("JOIN query_co_ba as query_co_ba1 on biological_associations.biological_association_subject_id = query_co_ba1.id AND biological_associations.biological_association_subject_type = 'CollectionObject'")

        b = ::BiologicalAssociation
          .joins("JOIN query_co_ba as query_co_ba2 on biological_associations.biological_association_object_id = query_co_ba2.id AND biological_associations.biological_association_object_type = 'CollectionObject'")

        s << referenced_klass_union([a,b]).to_sql

        ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      def field_occurrence_query_facet
        return nil if field_occurrence_query.nil?
        s = 'WITH query_fo_ba AS (' + field_occurrence_query.all.to_sql + ') '

        a = ::BiologicalAssociation
          .joins("JOIN query_fo_ba as query_fo_ba1 on biological_associations.biological_association_subject_id = query_fo_ba1.id AND biological_associations.biological_association_subject_type = 'FieldOccurrence'")

        b = ::BiologicalAssociation
          .joins("JOIN query_fo_ba as query_fo_ba2 on biological_associations.biological_association_object_id = query_fo_ba2.id AND biological_associations.biological_association_object_type = 'FieldOccurrence'")

        s << referenced_klass_union([a,b]).to_sql

        ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      # Brute-force style
      def taxon_name_query_facet
        return nil if taxon_name_query.nil?

        s = 'WITH query_tn_ba AS (' + taxon_name_query.all.to_sql + ') '

        a = ::BiologicalAssociation
          .joins("JOIN otus on otus.id = biological_associations.biological_association_subject_id AND biological_associations.biological_association_subject_type = 'Otu'")
          .joins('JOIN query_tn_ba as query_tn_ba1 on otus.taxon_name_id = query_tn_ba1.id')

        b = ::BiologicalAssociation
          .joins("JOIN otus on otus.id = biological_associations.biological_association_object_id AND biological_associations.biological_association_object_type = 'Otu'")
          .joins('JOIN query_tn_ba as query_tn_ba2 on otus.taxon_name_id = query_tn_ba2.id')

        c = ::BiologicalAssociation
          .joins("JOIN collection_objects on collection_objects.id = biological_associations.biological_association_subject_id AND biological_associations.biological_association_subject_type = 'CollectionObject'")
          .joins("JOIN taxon_determinations on taxon_determinations.taxon_determination_object_id = collection_objects.id AND taxon_determinations.taxon_determination_object_type = 'CollectionObject'")
          .joins('JOIN otus on otus.id = taxon_determinations.otu_id')
          .joins('JOIN query_tn_ba as query_tn_ba3 on otus.taxon_name_id = query_tn_ba3.id')
          .where('taxon_determinations.position = 1')

        d = ::BiologicalAssociation
          .joins("JOIN collection_objects on collection_objects.id = biological_associations.biological_association_object_id AND biological_associations.biological_association_object_type = 'CollectionObject'")
          .joins("JOIN taxon_determinations on taxon_determinations.taxon_determination_object_id = collection_objects.id AND taxon_determinations.taxon_determination_object_type = 'CollectionObject'")
          .joins('JOIN otus on otus.id = taxon_determinations.otu_id')
          .joins('JOIN query_tn_ba as query_tn_ba4 on otus.taxon_name_id = query_tn_ba4.id')
          .where('taxon_determinations.position = 1')

        s << referenced_klass_union([a,b,c,d]).to_sql

        ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      # Combines facets that apply to both BA itself and to subject/object.
      def biological_association_and_subject_object_facet
        # These are facets that need to be (individually) *unioned* with the
        # subject_object_facet and biological_associations_graph_geo_facet, not
        # intersected.
        # The final result, modulo nils, is just intersection(a) union b.
        a = [wkt_facet, geo_json_facet, biological_association_geo_facet].compact
        b = if biological_associations_graph_geo_facet.nil? &&
               subject_object_facet.nil?
              nil
            else
              referenced_klass_union(
                [biological_associations_graph_geo_facet, subject_object_facet]
              )
            end
        return b if a.empty?

        i = referenced_klass_intersection(a)
        referenced_klass_union([i, b])
      end

      def and_clauses
        [
          any_global_id_facet,
          biological_association_id_facet,
          biological_relationship_id_facet,
          object_object_global_id_facet,
          object_type_facet,
          subject_object_global_id_facet,
          subject_type_facet,
          biological_association_object_id_facet,
          biological_association_object_type_facet,
          biological_association_subject_id_facet,
          biological_association_subject_id_facet
        ]
      end

      def merge_clauses
        [
          asserted_distribution_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          field_occurrence_query_facet,
          otu_query_facet,
          taxon_name_query_facet,

          taxon_name_id_facet,
          biological_associations_graph_id_facet,
          object_biological_property_id_facet,
          subject_biological_property_id_facet,
          # This handles all Otu/CollectionObject attributes
          biological_association_and_subject_object_facet,
        ]
      end

      private

      def object_for(global_id)
        if o = GlobalID::Locator.locate(global_id)
          o
        else
          nil
        end
      end

      def matching_global_id(target = :subject, global_id = [])
        a = global_id
        b = "#{target}_matches".to_sym

        q = send(b, object_for(a[0]))
        a[1..a.length].each do |i|
          q = q.or( send(b, object_for(i) ))
        end
        q
      end

      # !! Plural is correct
      def object_taxon_name_ids
        return taxon_name_id if !taxon_name_id.empty?
        return object_taxon_name_id if !object_taxon_name_id.empty?
        return []
      end

      # !! Plural is correct
      def subject_taxon_name_ids
        return taxon_name_id if !taxon_name_id.empty? # only one or the other supposed to be sent
        return subject_taxon_name_id if !subject_taxon_name_id.empty?
        return []
      end

    end







       # Unused
      # rubocop:disable Metrics/MethodLength
      # This is "or"
      def subject_object_scope(subject_query, object_query, target = 'Otu')
        a = subject_query
        b = object_query

        a_sql, b_sql = nil, nil

        if !a.nil? && !a.only_project?
          a_sql = a.all.to_sql
        end

        if !b.nil? && !b.only_project?
          b_sql = b.all.to_sql
        end

        return nil if a_sql.nil? and b_sql.nil?

        # Setup for "WITH" use
        t = []
        t.push 'a_objects AS (' + a_sql + ')' if a_sql
        t.push 'b_objects AS (' + b_sql + ')' if b_sql && (b_sql != a_sql)

        s = 'WITH ' + t.join(', ')

        # subject/object queries reference different params
        if a_sql && b_sql && (a_sql != b_sql)
          s << ' ' + ::BiologicalAssociation
            .joins("LEFT JOIN a_objects as a_objects1 on a_objects1.id = biological_associations.biological_association_subject_id AND biological_associations.biological_association_subject_type = '" + target + "'")
            .joins("LEFT JOIN b_objects as b_objects1 on b_objects1.id = biological_associations.biological_association_object_id AND biological_associations.biological_association_object_type = '" + target + "'")
            .where('a_objects1.id is not null').or('b_objects1.id is not null')
            .to_sql

          # subject/object queries reference same params
        elsif a_sql && b_sql
          s << ' ' + ::BiologicalAssociation
            .joins("LEFT JOIN a_objects as a_objects1 on a_objects1.id = biological_associations.biological_association_subject_id AND biological_associations.biological_association_subject_type = '" + target + "'")
            .joins("LEFT JOIN a_objects as a_objects2 on a_objects2.id = biological_associations.biological_association_object_id AND biological_associations.biological_association_object_type = '" + target + "'")
            .where('a_objects1.id is not null').or('a_objects2.id is not null')
            .to_sql

          # subject only
        elsif a_sql
          s << ' ' + ::BiologicalAssociation
            .joins("JOIN a_objects as a_objects1 on a_objects1.id = biological_associations.biological_association_subject_id AND biological_associations.biological_association_subject_type = '" + target + "'")
            .to_sql

          # object_only
        else
          s << ' ' + ::BiologicalAssociation
            .joins("JOIN b_objects as b_objects1 on b_objects1.id = biological_associations.biological_association_object_id AND biological_associations.biological_association_object_type = '" + target + "'")
            .to_sql
        end

        return ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      # Unused
      def otu_facet
        subject_object_scope(subject_otu_query, object_otu_query, 'Otu' )
      end

      # Unused
      def collection_object_facet
        subject_object_scope(subject_collection_object_query, object_collection_object_query, 'CollectionObject' )
      end
  end
end
