module Queries
  module TaxonNameClassification
    class Filter < Queries::Query

      # @param taxon_name_id [String, Array, nil]
      #   Match all TaxonNameClassifications a taxon_name_id(s)
      attr_accessor :taxon_name_id

      # @param taxon_name_classification_type [String, Array, nil]
      #   the full class name like 'TaxonNameClassification::..etc.', or an Array of them 
      attr_accessor :taxon_name_classification_type

      # @param taxon_name_classification_set [Array, String, nil]
      #   one or more of 
      #     'validating',
      #     `invalidating`,
      #     `exceptions` 
      attr_accessor :taxon_name_classification_set

      # @param params [Params]
      def initialize(params)
        @taxon_name_id = params[:taxon_name_id]
        @taxon_name_classification_type = params[:taxon_name_classification_type]
        @taxon_name_classification_set = params[:taxon_name_classification_set]
      end

      # @return [Arel::Table]
      def table
        ::TaxonNameClassification.arel_table
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def taxon_name_classification_type
        [@taxon_name_classification_type].flatten.compact
      end

      def taxon_name_classification_set
        [@taxon_name_classification_set].flatten.compact
      end

      # @return [Array]
      def classification_types
        return [] if taxon_name_classification_set.empty?
        t = []

        taxon_name_classification_set.each do |i|
          t += TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID if i == 'invalidating'
          t += TAXON_NAME_CLASS_NAMES_VALID if i == 'validating'
          t += EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS if i == 'exceptions'
        end
        t
      end

      def taxon_name_classification_set_facet
        return nil if taxon_name_classification_set.empty?
        table[:type].eq_any(classification_types)
      end

      def taxon_name_classification_type_facet
        return nil if taxon_name_classification_type.empty?
        table[:type].eq_any(taxon_name_classification_type)
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        table[:taxon_name_id].eq_any(taxon_name_id)
      end

      def and_clauses
        clauses = []

        clauses += [
          taxon_name_id_facet,
          taxon_name_classification_type_facet,
          taxon_name_classification_set_facet,
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end     

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        # b = merge_clauses

        q = nil 
        if a
          q = ::TaxonNameClassification.where(a)
        else
          q = ::TaxonNameClassification.all
        end

        q = q.where(project_id: project_id) if project_id
        q
      end
    end

  end
end
