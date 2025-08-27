module Queries
  module TaxonNameRelationship
    class Filter < Query::Filter
      include Queries::Helpers

      include Queries::Concerns::Citations
      include Queries::Concerns::Notes
      include Queries::Concerns::Verifiers

      PARAMS = [
        :ancestors,
        :descendants,
        :object_taxon_name_id,
        :subject_taxon_name_id,
        :taxon_name_id,
        :taxon_name_relationship_set,
        :taxon_name_relationship_type,
        :taxon_name_relationship_id,
        :taxon_name_subject_object,
        object_taxon_name_id: [],
        subject_taxon_name_id: [],
        taxon_name_id: [],
        taxon_name_relationship_id: [],
        taxon_name_relationship_set: [],
        taxon_name_relationship_type: [],
      ].freeze

      # @param ancestors [Boolean, nil]
      #   Operate on ancestors of taxon_name_ids if true
      attr_accessor :ancestors

      # @param ancestors [Boolean, nil]
      #   Operate on descendants of taxon_name_ids if true
      attr_accessor :descendants

      # @param taxon_name_relationship_id [String, Array, nil]
      attr_accessor :taxon_name_relationship_id

      # @param taxon_name_id [String, Array, nil]
      #   On its own matches all relationships where either subject OR object is
      #   taxon_name_id(s), but also combines with taxon_name_subject_object,
      #   ancestors, and descendants.
      attr_accessor :taxon_name_id

      # @param taxon_name_relationship_type [String, Array, nil]
      #   the full class name like 'TaxonNameRelationship::..etc.', or an Array of them
      attr_accessor :taxon_name_relationship_type

      # @params subject_taxon_name_id [String, Array, nil]
      #    TaxonName id(s)
      # Match all relationships where subject is this ID
      attr_accessor :subject_taxon_name_id

      # @params object_taxon_name_id [String, Array, nil]
      #    TaxonName id(s)
      # Match all relationships where object is this ID
      attr_accessor :object_taxon_name_id

      # @param taxon_name_relationship_set [String, Array, nil]
      #   one or more of:
      #     'status',
      #     'synonym',
      #     'classification'
      #     'misspelling'
      # See corresponding constants in config/intialize/constants/taxon_name_relationships.rb
      attr_accessor :taxon_name_relationship_set

      # @param taxon_name_subject_object [String, nil]
      #   When 'subject', match taxon_name_id to subjects of relationships,
      #   when 'object', match taxon_name_id to objects of relationships,
      #   when nil, match to either subject or object.
      attr_accessor :taxon_name_subject_object

      # @param params [Params]
      def initialize(query_params)
        super

        @ancestors = boolean_param(params, :ancestors)
        @descendants = boolean_param(params, :descendants)
        @object_taxon_name_id = params[:object_taxon_name_id]
        @subject_taxon_name_id = params[:subject_taxon_name_id]
        @taxon_name_id = params[:taxon_name_id]
        @taxon_name_relationship_set = params[:taxon_name_relationship_set]
        @taxon_name_relationship_type = params[:taxon_name_relationship_type]
        @taxon_name_relationship_id = params[:taxon_name_relationship_id]
        @taxon_name_subject_object = params[:taxon_name_subject_object]

        set_citations_params(params)
        set_notes_params(params)
        set_verifiers_params(params)
      end

      def taxon_name_relationship_id
        [@taxon_name_relationship_id].flatten.compact
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

      def taxon_name_relationship_set
        [@taxon_name_relationship_set].flatten.compact
      end

      def taxon_name_relationship_type
        [@taxon_name_relationship_type].flatten.compact
      end

      # @return [Array]
      def relationship_types
        return [] unless taxon_name_relationship_set && taxon_name_relationship_set.any?
        t = []
        # TODO of_types =>
        taxon_name_relationship_set.each do |i|
          t += ::STATUS_TAXON_NAME_RELATIONSHIP_NAMES if i == 'status'
          t += ::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM if i == 'synonym'
          t += ::TAXON_NAME_RELATIONSHIP_NAMES_CLASSIFICATION if i == 'classification'
          t += ::TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING if i == 'misspelling'
        end
        t
      end

      def taxon_name_relationship_set_facet
        return nil unless taxon_name_relationship_set && taxon_name_relationship_set.any?
        table[:type].in(relationship_types)
      end

      def taxon_name_relationship_type_facet
        return nil unless taxon_name_relationship_type && taxon_name_relationship_type.any?
        table[:type].in(taxon_name_relationship_type)
      end

      def taxon_name_id_facet
        return nil if
          taxon_name_id.empty? || !ancestors.nil? || !descendants.nil?

        relationships_for_taxon_names_condition(taxon_name_id)
      end

      def ancestor_facet
        return nil if taxon_name_id.empty? || !ancestors

        names = ::Queries::TaxonName::Filter.new(taxon_name_id:, ancestors:).all
        relationships_for_taxon_names_condition(names)
      end

      def descendant_facet
        return nil if taxon_name_id.empty? || descendants.nil?

        names = ::Queries::TaxonName::Filter.new(taxon_name_id:, descendants:).all
        relationships_for_taxon_names_condition(names)
      end

      # @param taxon_names [Array or scope of TaxonName ids]
      def relationships_for_taxon_names_condition(taxon_names)
        if taxon_names.is_a?(ActiveRecord::Relation)
          taxon_names = taxon_names.reselect(:id).arel
        end

        if taxon_name_subject_object == 'subject'
          table[:subject_taxon_name_id].in(taxon_names)
        elsif taxon_name_subject_object == 'object'
          table[:object_taxon_name_id].in(taxon_names)
        else
          table[:subject_taxon_name_id].in(taxon_names)
            .or(
              table[:object_taxon_name_id].in(taxon_names)
            )
        end
      end

      # @return [ActiveRecord::Relation, nil]
      def as_subject_facet
        return nil if subject_taxon_name_id.empty?
        table[:subject_taxon_name_id].in(subject_taxon_name_id)
      end

      # @return [ActiveRecord::Relation, nil]
      def as_object_facet
        return nil if object_taxon_name_id.empty?
        table[:object_taxon_name_id].in(object_taxon_name_id)
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?

        a = ::TaxonNameRelationship
          .with(tn_query: taxon_name_query.all)
          .joins(:subject_taxon_name)
          .where('taxon_name_relationships.subject_taxon_name_id IN (SELECT id FROM tn_query)')

        b = ::TaxonNameRelationship
          .with(tn_query: taxon_name_query.all)
          .joins(:object_taxon_name)
          .where('taxon_name_relationships.object_taxon_name_id IN (SELECT id FROM tn_query)')

        referenced_klass_union([a,b])
      end

      def and_clauses
        [
          ancestor_facet,
          descendant_facet,
          taxon_name_relationship_type_facet,
          taxon_name_relationship_set_facet,
          taxon_name_id_facet,
          as_subject_facet,
          as_object_facet,
        ]
      end

      def merge_clauses
        [
          taxon_name_query_facet,
        ]
      end
    end
  end
end
