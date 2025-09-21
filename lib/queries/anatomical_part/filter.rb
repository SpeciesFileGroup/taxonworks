module Queries
  module AnatomicalPart
    class Filter < Query::Filter
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations

      PARAMS = [

      ].freeze


      # @param params [Hash]
      def initialize(query_params)
        super

        set_citations_params(params)
        set_tags_params(params)
      end

      def and_clauses
        [
        ]
      end

      def merge_clauses
        [
        ]
      end

    end
  end
end
