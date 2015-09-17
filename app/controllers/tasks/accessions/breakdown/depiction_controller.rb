
class Tasks::Accessions::Breakdown::DepictionController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/accession/breakdown/depiction/:id
  def index
    @result = SqedToTaxonworks::Result.new(
      depiction_id:  params[:depiction_id],
      namespace_id: params[:namespace_id]
    )
  end

  def update 
    @depiction = Depiction.find(params[:id])
    
    if @depiction.depiction_object.update(collection_object_params)
      flash[:notice] = 'Successfully updated'
    else
      flash[:alert] = 'Failed to update! ' + @depiction.depiction_object.errors.full_messages.join("; ").html_safe
    end

    next_depiction = (params[:commit] == 'Save and next' ? SqedDepiction.next_depiction(@depiction) : @depiction )
    namespace_id = (params[:lock_namespace] ? params[:collection_object][:identifiers_attributes][:namespace_id] : nil)

    redirect_to depiction_breakdown_task_path(next_depiction, namespace_id)
  end

  def collection_object_params
    params.require(:collection_object).permit(
      :buffered_collecting_event, :buffered_other_labels, :buffered_determinations, :total,
      identifiers_attributes: [:id, :namespace_id, :identifier, :type, :_destroy],
      taxon_determinations_attributes: [:otu_id, :_destroy]
    )
  end

end
