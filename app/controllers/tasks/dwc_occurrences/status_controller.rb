class Tasks::DwcOccurrences::StatusController < ApplicationController
  include TaskControllerConfiguration

  # after_action -> { set_pagination_headers(:dwc_occurrences) }, only: [:index]

  def index
    @dwc_occurrences_query = Queries::DwcOccurrence::Filter.new(params)

    @dwc_occurrences =  @dwc_occurrences_query.all
      .where(project_id: sessions_current_project_id)
      .select(:id, :updated_at, :dwc_occurrence_object_type, :dwc_occurrence_object_id, :scientificName, :fieldNumber)
      .page(params[:page])
      .per(params[:per] || 200)
  end

end
