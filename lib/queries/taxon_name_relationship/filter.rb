module Queries
  module TaxonNameRelationship
    class Filter < Query::Filter

      PARAMS = [
        :object_taxon_name_id,
        :subject_taxon_name_id,
        :taxon_name_id,
        :taxon_name_relationship_set,
        :taxon_name_relationship_type,
        object_taxon_name_id: [],
        subject_taxon_name_id: [],
        taxon_name_id: [],
        taxon_name_relationship_set: [],
        taxon_name_relationship_type: [],
      ]

      # @param taxon_name_id [String, Array, nil]
      #   Match all relationships where either subject OR object is taxon_name_id(s)
      attr_accessor :taxon_name_id

      # @param as_object [Boolean, nil]
      #   if taxon_name_id and true then treat as subject
      attr_accessor :as_object

      # @param as_subject [Boolean, nil]
      #   if taxon_name_id and true then treat as subject
      attr_accessor :as_subject

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
      # See corresponding constants in config/intialize/constants/taxon_name_relationships.rb
      attr_accessor :taxon_name_relationship_set

      # @param params [Params]
      def initialize(params)
        @taxon_name_id = params[:taxon_name_id]

        @subject_taxon_name_id = params[:subject_taxon_name_id]
        @object_taxon_name_id = params[:object_taxon_name_id]

        @as_object = (params[:as_object]&.to_s&.downcase == 'true' ? true : false) if !params[:as_object].nil?
        @as_subject = (params[:as_subject]&.to_s&.downcase == 'true' ? true : false) if !params[:as_subject].nil?

        @taxon_name_relationship_type = [params[:taxon_name_relationship_type]].flatten.compact
        @taxon_name_relationship_set = [params[:taxon_name_relationship_set]].flatten.compact

        super
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

      # @return [Array]
      def relationship_types
        return [] unless taxon_name_relationship_set && taxon_name_relationship_set.any?
        t = []
        # TODO of_types =>
        taxon_name_relationship_set.each do |i|
          t += ::STATUS_TAXON_NAME_RELATIONSHIP_NAMES if i == 'status'
          t += ::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM if i == 'synonym'
          t += ::TAXON_NAME_RELATIONSHIP_NAMES_CLASSIFICATION if i == 'classification'
        end
        t
      end

      def taxon_name_relationship_set_facet
        return nil unless taxon_name_relationship_set && taxon_name_relationship_set.any?
        table[:type].eq_any(relationship_types)
      end

      def taxon_name_relationship_type_facet
        return nil unless taxon_name_relationship_type && taxon_name_relationship_type.any?
        table[:type].eq_any(taxon_name_relationship_type)
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        table[:subject_taxon_name_id].eq_any(taxon_name_id)
          .or(
            table[:object_taxon_name_id].eq_any(taxon_name_id)
          )
      end

      # @return [ActiveRecord::Relation, nil]
      def as_subject_facet
        return nil if subject_taxon_name_id.empty?
        table[:subject_taxon_name_id].eq_any(subject_taxon_name_id)
      end

      # @return [ActiveRecord::Relation, nil]
      def as_object_facet
        return nil if object_taxon_name_id.empty?
        table[:object_taxon_name_id].eq_any(object_taxon_name_id)
      end

      def and_clauses
        [
          taxon_name_relationship_type_facet,
          taxon_name_relationship_set_facet,
          taxon_name_id_facet,
          as_subject_facet,
          as_object_facet,
        ]
      end     

  end
end
