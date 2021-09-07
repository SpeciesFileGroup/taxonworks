class DwcOccurrencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def metadata
    @dwc_occurrences = DwcOccurrence.where(project_id: sessions_current_project_id)
  end

  def predicates
  end

  def status
    if @object = GlobalID::Locator.locate(params[:object_global_id])
      render json: {
        object: params[:object_global_id],
        id: @object.dwc_occurrence&.id,
        updated_at:  @object.dwc_occurrence&.updated_at
      }
    else
      render json: {}, status: :unprocessable_entity
    end
  end

end
