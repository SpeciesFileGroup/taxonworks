module Queries
  module People
    class Filter
      # @params params [ActionController::Parameters]
      def initialize(params)
        @keyword_id = [params[:keyword_id]].flatten.compact
        @options = params
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
            Queries::Annotator.annotator_params(options, ::Tag),
            matching_keyword_id,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::People.where(and_clauses)
        else
          ::People.none
        end
      end

      # @return [Arel::Table]
      def table
        ::People.arel_table
      end
    end
  end
end