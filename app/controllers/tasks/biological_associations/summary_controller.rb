class Tasks::BiologicalAssociations::SummaryController < ApplicationController
  include TaskControllerConfiguration

  # No iteration through all records, just query summaries
  def index
    @biological_associations_query = ::Queries::BiologicalAssociation::Filter.new(params)
    @biological_associations = @biological_associations_query.all
  end

end
