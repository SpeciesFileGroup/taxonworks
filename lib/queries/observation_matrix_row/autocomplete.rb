module Queries

  module ObservationMatrixRow
  # A wrapper around Otu and CollectionObject filters
  class Autocomplete < Query::Autocomplete

    attr_accessor :observation_matrix_id

    def initialize(string, project_id: nil, observation_matrix_id: nil)
      super
      @observation_matrix_id = observation_matrix_id
    end

    # @return [Array]
    #   TODO: optimize limits
    def autocomplete

      a = Queries::Otu::Autocomplete.new(query_string, project_id: project_id).base_queries
      b = Queries::CollectionObject::Autocomplete.new(query_string, project_id: project_id).base_queries

      return [] if a.nil? && b.nil?
      updated_queries = []

      a.each do |q|
        j = ::ObservationMatrixRow.joins(:otu).where(otu: q.limit(50).pluck(:id)).order('observation_matrix_rows.position')
        c = j.where(observation_matrix_id: observation_matrix_id) if observation_matrix_id
        c ||= j
        updated_queries.push c
      end

      b.each do |q|
        j = ::ObservationMatrixRow.joins(:collection_object).where(otu: q.limit(50).pluck(:id)).order('observation_matrix_rows.position')
        c = j.where(observation_matrix_id: observation_matrix_id) if observation_matrix_id
        c ||= j
        updated_queries.push c
      end

      result = []
      updated_queries.each do |q|
        result += q.to_a
        result.uniq!
        break if result.count > 50
      end
      result[0..49]
    end
  end
end
