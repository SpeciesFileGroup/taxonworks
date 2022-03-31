class Tasks::Accessions::ComprehensiveController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    if params[:dwc_occurrence_id]
      dwc_occurrence = DwcOccurrence.where(project_id: sessions_current_project_id).find(params[:dwc_occurrence_id])
      if dwc_occurrence.dwc_occurrence_object_type == 'CollectionObject'
        redirect_to comprehensive_collection_object_task_path(collection_object_id: dwc_occurrence.dwc_occurrence_object_id) and return
      end
    end
  end

end
