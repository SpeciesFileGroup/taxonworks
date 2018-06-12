module Queries
  module Person
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
          ::Person.where(and_clauses)
        else
          ::Person.none
        end
      end

      # @return [Arel::Table]
      def table
        ::Person.arel_table
      end
    end
  end
end
