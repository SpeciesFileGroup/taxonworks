class Tasks::Accessions::Breakdown::SqedDepictionController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_sqed_depiction, except: [:todo_map]

  # GET /tasks/accession/breakdown/depiction/:id
  def index
    @result = SqedToTaxonworks::Result.new(
      depiction_id: @sqed_depiction.depiction.id,
      namespace_id: params[:namespace_id]
    )

    @identifier_prototype = Identifier.prototype_identifier(sessions_current_project_id, sessions_current_user_id)
  end

  def update
    if @sqed_depiction.depiction.depiction_object.update(collection_object_params)
      flash[:notice] = 'Successfully updated'
    else
      flash[:alert] = 'Failed to update! ' + @sqed_depiction.depiction.depiction_object.errors.full_messages.join('; ').html_safe
    end

    next_sqed_depiction = (params[:commit] == 'Save and next [n]' ? @sqed_depiction.next_without_data : @sqed_depiction )
    namespace_id = (params[:lock_namespace] ? params[:collection_object][:identifiers_attributes]['0'][:namespace_id] : nil)

    redirect_to sqed_depiction_breakdown_task_path(next_sqed_depiction, namespace_id)
  end

  def todo_map
    @sqed_depictions = SqedDepiction.with_project_id(sessions_current_project_id).order(:id).page(params[:page]).per(100)
  end

  protected

  def collection_object_params
    params.require(:collection_object).permit(
      :buffered_collecting_event, :buffered_other_labels, :buffered_determinations, :total,
      identifiers_attributes: [:id, :namespace_id, :identifier, :type, :_destroy],
      tags_attributes: [:id, :keyword_id, :_destroy],
      taxon_determinations_attributes: [:id, :otu_id, :_destroy],
      notes_attributes: [:id, :text, :_destroy]
    )
  end


  def set_sqed_depiction
    @sqed_depiction = SqedDepiction.find(params[:id])
    @sqed_depiction.preprocess
  end

end
