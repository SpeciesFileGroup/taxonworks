module Queries
  module ObservationMatrixRow
    class Filter < Queries::Query

      attr_accessor :observation_object_type
      attr_accessor :observation_object_id
      attr_accessor :observation_matrix_id

      # @params observation_object_id_vector [String, nil]
      #   a vector of ids in the format `123|456|790|`
      attr :observation_object_id_vector

      def initialize(params)
        @observation_object_type = params[:observation_object_type]
        @observation_object_id = params[:observation_object_id]
        @project_id = params[:project_id]
        @observation_object_id_vector = params[:observation_object_id_vector]
        @observation_matrix_id = params[:observation_matrix_id]
      end

      def base_query
        ::ObservationMatrixRow.select('observation_matrices.*')
      end

      def table
        ::ObservationMatrixRow.arel_table
      end

      def observation_object_id
        [@observation_object_id].flatten.compact +  
          (observation_object_id_vector.blank? ? [] : observation_object_id_vector.split('|'))
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_observation_matrix_id,
          matching_observation_object_id,
          matching_observation_object_type,
        ].compact
      
        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def merge_clauses
        clauses = []

        return nil if clauses.empty?
      end

      def matching_observation_matrix_id
        observation_matrix_id.empty? ? nil : table[:observation_matrix_id].eq_any(observation_matrix_id)
      end

      def matching_observation_object_id
        observation_object_id.empty? ? nil : table[:observation_object_id].eq_any(observation_object_id)
      end

      def matching_observation_object_type
        observation_object_type.blank? ? nil : table[:observation_object_type].eq(observation_object_type)
      end

      # @return [String, nil]
      def where_sql
        a = and_clauses
        return nil if a.nil?
        a.to_sql
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        q = nil
        if a && b
          q = b.where(a)
        elsif a
          q = ::ObservationMatrixRow.where(a)
        elsif b
          q = b
        else
          q = ::ObservationMatrixRow.all
        end

        q = q.where(project_id: project_id) if project_id
        q
      end

    end
  end
end
