module Queries
  module ObservationMatrix 
    class Filter < Queries::Query

      attr_accessor :observation_matrix_id

      def initialize(params = {})
        @observation_matrix_id
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_observation_matrix_id,
        ].compact
      
        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end

        a
      end

      def matching_observation_matrix_id
        observation_matrix_id.empty? ? nil : table[:id].eq_any(observation_matrix_id)
      end

      # @return [String, nil]
      def where_sql
        a = and_clauses
        return nil if a.nil?
        a.to_sql
      end

      def all
        if w = where_sql
          base_query.where(w).distinct
        else
          base_query.all
        end
      end

      # @return [Arel::Table]
      def table
        ::ObservationMatrix.arel_table
      end

      def base_query
        ::ObservationMatrix.select('observation_matrices.*')
      end

    end
  end
end
