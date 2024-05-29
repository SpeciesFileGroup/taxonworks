class Tasks::DwcOccurrences::FilterController < ApplicationController
  include TaskControllerConfiguration

  after_action -> { set_pagination_headers(:dwc_occurrences) }, only: [:index]

  def index
    @dwc_occurrences = Queries::DwcOccurrence::Filter.new(params).all
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per] || 1)
  end

end
