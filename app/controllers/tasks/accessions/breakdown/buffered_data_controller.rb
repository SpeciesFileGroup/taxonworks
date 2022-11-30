class Tasks::Accessions::Breakdown::BufferedDataController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_collection_object, only: [:index, :update]

  # GET /tasks/accession/breakdown/buffered_data/:id
  def index
    @collection_object.collecting_event = CollectingEvent.new if @collection_object.collecting_event.nil?
    @collection_object.collecting_event.identifiers.build(type: 'Identifier::Local::AccessionCode')
  end

  def thumb_navigator
    render partial: '/tasks/accessions/breakdown/buffered_data/thumb_navigator', locals: { sqed_depiction: SqedDepiction.find(params[:id])  }
  end

  def update
    @collection_object.update(collection_object_params)
    @collection_object.valid?
    flash[:notice] = 'Collection object was' + (@collection_object.valid? ? '' : ' NOT') + ' successfully updated.' + (@collection_object.valid? ? '' : @collection_object.errors.full_messages.join('; '))

    respond_to do |format|
      if params[:commit] == 'Save changes'
        format.html { redirect_to collection_object_buffered_data_breakdown_task_path(@collection_object) }
      elsif params[:commit] == 'Save and next'
        if @collection_object.valid?
          format.html { redirect_to collection_object_buffered_data_breakdown_task_path(@result.sqed_depiction.next_collection_object)  }
        else
          format.html { redirect_to collection_object_buffered_data_breakdown_task_path(@collection_object) }
        end
      end
    end
  end

  protected

  def collection_object_params
    params.require(:collection_object).permit(
      :buffered_collecting_event, # :buffered_other_labels, :buffered_determinations, :total,
      collecting_event_attributes: [:id, :verbatim_locality, :geographic_area_id,
                                    identifiers_attributes:
                                    [:id, :namespace_id, :identifier, :type, :_destroy]],
    # tags_attributes: [:id, :keyword_id, :_destroy],
      # taxon_determinations_attributes: [:id, :otu_id, :_destroy],
      # notes_attributes: [:id, :text, :_destroy]
    )
  end

  def set_collection_object
    # collection object that has SqedDepiction
    @collection_object = CollectionObject.where(project_id: sessions_current_project_id).find(params[:id])
    @result = SqedToTaxonworks::Result.new(
      depiction_id: @collection_object.depictions.first.id,
    )
  end

  def set_sqed_depiction
    @sqed_depiction = SqedDepiction.where(project_id: sessions_current_project_id).find(params[:id])
  end

end
