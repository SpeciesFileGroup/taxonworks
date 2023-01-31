require 'queries/taxon_name/filter'
module Queries
  module BiologicalAssociation

    class Filter < Query::Filter
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags

      PARAMS = [
        :biological_association_id,
        :biological_associations_graph_id,
        :biological_relationship_id,
        :collecting_event_id,
        :collection_object_id,
        :descendants,
        :geo_json,
        :geo_json,
        :geographic_area_id,
        :geographic_area_mode,
        :geographic_area_mode,
        :object_biological_property_id,
        :object_global_id,
        :object_taxon_name_id,
        :object_type,
        :subject_biological_property_id,
        :subject_global_id,
        :subject_taxon_name_id,
        :subject_type,
        :taxon_name_id,
        :taxon_name_id_mode,
        :wkt,

        any_global_id: [],
        biological_association_id: [],
        biological_associations_graph_id: [],
        biological_relationship_id: [],
        collecting_event_id: [],
        collection_object_id: [],
        geographic_area_id: [],
        object_biological_property_id: [],
        object_global_id: [],
        object_taxon_name_id: [],
        otu_id: [],
        subject_biological_property_id: [],
        subject_global_id: [],
        subject_taxon_name_id: [],
        taxon_name_id: [],
      ].freeze


      # Params to consider for OTU scopes
      #  !! taxon_name_id, object_taxon_name_id, subject_taxon_name_id, otu_id and descendants are handled seperately
      OTU_PARAMS = %i{
        collecting_event_id
        collection_object_id
        geo_json
        geographic_area_id
        geographic_area_mode
        otu_id
        wkt
      }.freeze

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
      # ??TODO: TaxonNames must be valid!
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
      # @param biological_relationship_id [Array, Integer]
      attr_accessor :biological_relationship_id

      # @return [Array]
      #   a biological relationship graph ID
      # @param biological_associations_graph_id [Array, Integer]
      attr_accessor :biological_associations_graph_id

      # @return [Array]
      attr_accessor :subject_global_id

      # @return [Array]
      attr_accessor :object_global_id

      # @return [Array]
      attr_accessor :any_global_id

      # See lib/queries/otu/filter.rb
      attr_accessor :wkt
      attr_accessor :geo_json
      attr_accessor :geographic_area_id

      attr_accessor :geographic_area_mode

      # @return [nil, 'Otu', 'CollectionObject']
      #  limit subject to a type
      attr_accessor :subject_type

      # @return [nil, 'Otu', 'CollectionObject']
      #  limit object to a type
      attr_accessor :object_type

      def initialize(params)
        @any_global_id = params[:any_global_id]
        @biological_association_id = params[:biological_association_id]
        @biological_associations_graph_id = params[:biological_associations_graph_id]
        @biological_relationship_id = params[:biological_relationship_id]
        @collecting_event_id = params[:collecting_event_id]
        @collection_object_id = params[:collection_object_id]
        @descendants = boolean_param(params, :descendants)
        @geo_json = params[:geo_json]
        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @object_biological_property_id = params[:object_biological_property_id]
        @object_global_id = params[:object_global_id]
        @object_taxon_name_id = params[:object_taxon_name_id]
        @object_type = params[:object_type]
        @otu_id = params[:otu_id]
        @subject_biological_property_id = params[:subject_biological_property_id]
        @subject_global_id = params[:subject_global_id]
        @subject_taxon_name_id = params[:subject_taxon_name_id]
        @subject_type = params[:subject_type]
        @taxon_name_id = params[:taxon_name_id]
        @taxon_name_id_mode = boolean_param(params, :taxon_name_id_mode)
        @wkt = params[:wkt]

        set_notes_params(params)
        set_tags_params(params)
        super
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

      def biological_relationship_id
        [@biological_relationship_id].flatten.compact
      end

      def biological_associations_graph_id
        [@biological_associations_graph_id].flatten.compact
      end

      def subject_global_id
        [@subject_global_id].flatten.compact
      end

      def object_global_id
        [@object_global_id].flatten.compact
      end

      def any_global_id
        [@any_global_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      # @return [ActiveRecord object, nil]
      # TODO: DRY
      def object_for(global_id)
        if o = GlobalID::Locator.locate(global_id)
          o
        else
          nil
        end
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

      #--

      def collection_object_params
        h = {}
        OTU_PARAMS.each do |p|
          v = send(p)
          h[p] = v if v.present?
        end
        h
      end

      # TODO: same as co for now ?!
      def otu_params
        h = {}
        OTU_PARAMS.each do |p|
          v = send(p)
          h[p] = v if v.present?
        end
        h
      end

      #----

      def object_taxon_name_ids
        return taxon_name_id if taxon_name_id.present?
        return object_taxon_name_id if object_taxon_name_id.present?
        return nil
      end

      def subject_taxon_name_ids
        return taxon_name_id if taxon_name_id.present?
        return subject_taxon_name_id if subject_taxon_name_id.present?
        return nil
      end

      def base_otu_query(opts)
        q = ::Queries::Otu::Filter.new(opts)
        q.project_id = nil # reset at use
        q
      end

      def base_collection_object_query(opts)
        q = ::Queries::CollectionObject::Filter.new(opts)
        q.project_id = nil
        q
      end

      def subject_collection_object_query
        p = collection_object_params
        s = subject_taxon_name_ids

        if p.blank? && s.nil?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        q = base_collection_object_query(p)
      end

      def object_collection_object_query
        p = collection_object_params
        s = object_taxon_name_ids

        if p.blank? && s.nil?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        q = base_collection_object_query(p)
      end

      def subject_otu_query
        p = otu_params
        s = subject_taxon_name_ids

        if p.blank? && s.nil?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        base_otu_query(p)
      end

      def object_otu_query
        p = otu_params
        s = object_taxon_name_ids

        if p.blank? && s.nil?
          return nil
        elsif s.present?
          p[:taxon_name_id] = s
          p[:descendants] = descendants
        end

        base_otu_query(p)
      end

      def otu_facet
        subject_object_scope(subject_otu_query, object_otu_query, 'Otu' )
      end

      def collection_object_facet
        subject_object_scope(subject_collection_object_query, object_collection_object_query, 'CollectionObject' )
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

        a_sql, b_sql = nil, nil

        if !a&.all(true).nil?
          a.project_id = project_id
          a_sql = a.all.to_sql
        end

        if !b&.all(true).nil?
          b.project_id = project_id
          b_sql = b.all.to_sql
        end

        return nil if a_sql.nil? and b_sql.nil?

        # Setup for "WITH" use
        a_with = "WITH a_#{target}_objects AS (" + a_sql + ') ' if a_sql
        b_with = "WITH b_#{target}_objects AS (" + b_sql + ') ' if b_sql

        d, e = nil, nil 
        
        if a_with
          d = a_with + ::BiologicalAssociation
            .joins("JOIN a_#{target}_objects as a_#{target}_objects1 on a_#{target}_objects1.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'Otu'").to_sql
        end

        if b_with
          e = b_with + ::BiologicalAssociation
            .joins("JOIN b_#{target}_objects as b_#{target}_objects1 on b_#{target}_objects1.id = biological_associations.biological_association_#{target}_id AND biological_associations.biological_association_#{target}_type = 'CollectionObject'").to_sql
        end

        return ::BiologicalAssociation.from(
          '(' + [d,e].compact.collect{|q| '(' + q + ')'}.join(' UNION ') + ') as biological_associations'
        )
      end

      # Merges results from Otu and CollectionObject filters 
      # as the basis for the query
      def subject_object_facet
        a = subject_scope
        b = object_scope

        return nil if a.nil? && b.nil?

        case taxon_name_id_mode
        when true # and
          ::BiologicalAssociation.from(
            '(' + [a,b].compact.collect{|q| '(' + q.to_sql + ')'}.join(' INTERSECT ') + ') as biological_associations'
          )
        when false, nil # or
          ::BiologicalAssociation.from(
            '(' + [a,b].compact.collect{|q| '(' + q.to_sql + ')'}.join(' UNION ') + ') as biological_associations'
          )
        end
      end

      # rubocop:disable Metrics/MethodLength
      # !! PostgreSQL specific (uses "WITH")
      def subject_object_scope(subject_query, object_query, target = 'Otu', mode: :or)
        a = subject_query
        b = object_query

        a_sql, b_sql = nil, nil

        if !a&.all(true).nil?
          a.project_id = project_id
          a_sql = a.all.to_sql
        end

        if !b&.all(true).nil?
          b.project_id = project_id
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

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        ::BiologicalAssociation.where(
          table[:biological_association_subject_id].eq_any(collection_object_id).and(table[:biological_association_subject_type].eq('CollectionObject')
          .or( table[:biological_association_object_id].eq_any(collection_object_id).and(table[:biological_association_object_type].eq('CollectionObject'))))
        )
      end

      def subject_global_id_facet
        return nil if subject_global_id.empty?
        matching_global_id(:subject, subject_global_id)
      end

      def object_global_id_facet
        return nil if object_global_id.empty?
        matching_global_id(:object, object_global_id)
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
        table[:biological_relationship_id].eq_any(biological_relationship_id)
      end

      def biological_association_id_facet
        return nil if biological_association_id.empty?
        table[:id].eq_any(biological_association_id)
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

        s = 'WITH query_ce_ba AS (' + collecting_event_query.all.to_sql + ') ' + 
          ::BiologicalAssociation
          .joins("LEFT JOIN collection_objects co1 on co1.id = biological_associations.biological_association_subject_id AND biological_associations.biological_association_subject_type = 'CollectionObject'")
          .joins("LEFT JOIN collection_objects co2 on co2.id = biological_associations.biological_association_object_id AND biological_associations.biological_association_object_type = 'CollectionObject'")
          .joins('LEFT JOIN query_ce_ba as query_ce_ba1 on co1.collecting_event_id = query_ce_ba1.id')
          .joins('LEFT JOIN query_ce_ba as query_ce_ba2 on co2.collecting_event_id = query_ce_ba2.id')
          .where('co1.id IS NOT NULL OR query_ce_ba2.id IS NOT NULL')
          .to_sql

        ::BiologicalAssociation.from('(' + s + ') as biological_associations')
      end

      def and_clauses
        [
          any_global_id_facet,
          biological_association_id_facet,
          biological_relationship_id_facet,
          object_global_id_facet,
          object_type_facet,
          subject_global_id_facet,
          subject_type_facet,
        ]
      end

      def merge_clauses
        [
          source_query_facet,
          collecting_event_query_facet,

          biological_associations_graph_id_facet,
          collection_object_id_facet,
          object_biological_property_id_facet,
          subject_biological_property_id_facet,
          subject_object_facet,
        ]
      end

      private

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
  end
end
