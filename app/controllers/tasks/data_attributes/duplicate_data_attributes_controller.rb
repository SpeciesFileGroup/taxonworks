# Controller for the Duplicate Data Attributes report task.
# Identifies objects that have more than one DataAttribute with the same Predicate.
# Claude provided > 50% of the code for this class.
class Tasks::DataAttributes::DuplicateDataAttributesController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  # Returns JSON data of objects with duplicate predicates.
  # Accepts filter query parameters (e.g., otu_query, collection_object_query).
  def data
    filter = Queries::Query::Filter.instantiated_base_filter(params)

    if filter.nil? || filter.params.empty?
      render json: { error: 'No valid filter query provided' }, status: :unprocessable_content
      return
    end

    result = helpers.duplicate_predicate_data(filter, sessions_current_project_id)
    render json: result
  end

end
