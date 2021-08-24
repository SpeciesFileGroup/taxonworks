class DwcOccurrencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def metadata
    @dwc_occurrences = DwcOccurrence.where(project_id: sessions_current_project_id)
  end

  def predicates
  end

end
