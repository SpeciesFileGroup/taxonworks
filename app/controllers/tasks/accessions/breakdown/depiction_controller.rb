
class Tasks::Accessions::Breakdown::DepictionController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/accession/breakdown/depiction/:id
  def index
    @result = SqedToTaxonworks::Result.new(
      depiction_id:  params[:depiction_id],
      user_id: @sessions_current_user_id,
      project_id: @sessions_current_project_id,
    )
  end

  def create
    @depiction = Depiction.find(params[:id])
    @depiction.depiction_object.update(collection_object_params)
    redirect_to depiction_breakdown_task_path(@depiction)
  end

  def collection_object_params
    params.require(:collection_object).permit()
  end


end
