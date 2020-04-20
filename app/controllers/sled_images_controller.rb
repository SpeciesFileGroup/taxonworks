class SledImagesController < ApplicationController
  before_action :set_sled_image, only: [:update, :destroy, :show]

  def show
  end

  # POST /sled_images.json
  def create
    @sled_image = SledImage.new(sled_image_params)
    if @sled_image.save
       render :show, status: :created, location: @sled_image
    else
      render json: @sled_image.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sled_images/1.json
  def update
    if @sled_image.update(sled_image_params)
      render :show, status: :ok, location: @sled_image
    else
      render json: @sled_image.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sled_images/1.json
  def destroy
    @sled_image.nuke = params[:nuke]
    @sled_image.destroy
    respond_to do |format|
      format.html { redirect_to sled_images_url, notice: 'Sled image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_sled_image
    @sled_image = SledImage.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def sled_image_params
    params.require(:sled_image).permit( :image_id,
      :step_identifier_on,
      metadata: [
        :index, :row, :column, :metadata,
        lowerCorner: [:x, :y],
        upperCorner: [:x, :y]
      ],
      object_layout: {} # todo
    ).merge(
      collection_object_params: collection_object_params,
      depiction_params: depiction_params
    )
  end

  def depiction_params
    params[:depiction]&.permit(:is_metadata_depiction) || {}
  end

  def collection_object_params
    params[:collection_object]&.permit(
      :total,
      :collecting_event_id,
      :repository_id,
      :preparation_type_id,
      identifiers_attributes: [:namespace_id, :identifier, :type],
      notes_attributes: [:text],
      tags_attributes: [:id, :_destroy, :keyword_id],
      data_attributes_attributes: [ :id, :_destroy, :controlled_vocabulary_term_id, :type, :value ], # not yet implemented
      taxon_determinations_attributes: [
        :id, :_destroy, :otu_id, :year_made, :month_made, :day_made,
        roles_attributes: [
          :id, :_destroy, :type, :person_id, :position,
          person_attributes: [:last_name, :first_name, :suffix, :prefix]
        ]
      ]
    ) || {}
  end

end
