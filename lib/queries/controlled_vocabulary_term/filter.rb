module Queries
  module ControlledVocabularyTerm
    class Filter < Query::Filter
      include Queries::Helpers

      PARAMS = [
        :controlled_vocabulary_term_id,
        :type,
        controlled_vocabulary_term_id: [],
      ].freeze

      attr_accessor :type

      # @return [Array]
      attr_accessor :controlled_vocabulary_term_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super

        @type = params[:type]
      end

      def controlled_vocabulary_term_id
        [@controlled_vocabulary_term_id].flatten.compact.uniq
      end

      # @return [Arel::Node, nil]
      def matching_type
        type.blank? ? nil : table[:type].eq(type)
      end

      # Not very optimized (unused at moment)
      def data_attribute_query_facet
        return nil if data_attribute_query.nil?
        d = data_attribute_query.all.select(:controlled_vocabulary_term_id).distinct
        s = 'WITH query_cvt_da AS (' + d.to_sql + ') ' +
            ::ControlledVocabularyTerm
              .joins('JOIN query_cvt_da as query_cvt_da1 on query_cvt_da1.controlled_vocabulary_term_id = controlled_vocabulary_terms.id')
              .to_sql

        ::ControlledVocabularyTerm.from('(' + s + ') as controlled_vocabulary_terms').distinct
      end

      def merge_clauses
        [ data_attribute_query_facet]
      end

      def and_clauses
        [
          matching_type,
        ]
      end

    end
  end
end
