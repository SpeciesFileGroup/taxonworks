class CompositionItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_composition_item, only: [:show, :update, :destroy]
  before_action :check_composition, only: [:create, :update]

  # GET /compositions/:composition_id/composition_items.json
  # All items of the Composition, unpaged: a renderer needs them all.
  def index
    @composition_items = Composition
      .visible_to_project(sessions_current_project_id)
      .find(params.require(:composition_id))
      .composition_items
      .includes(:composition_item_object)
      .order(
        CompositionItem.arel_table[:parent_id].asc.nulls_first, :position
      )
  end

  # GET /composition_items/1.json
  def show
  end

  # POST /composition_items.json
  def create
    @composition_item = CompositionItem.new(
      composition_item_params.merge(
        type: params.dig(:composition_item, :type)
      )
    )
    if @composition_item.save
      render :show, status: :created,
        location: @composition_item.metamorphosize
    else
      render json: @composition_item.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /composition_items/1.json
  def update
    if @composition_item.update(composition_item_params)
      render :show, status: :ok,
        location: @composition_item.metamorphosize
    else
      render json: @composition_item.errors, status: :unprocessable_content
    end
  end

  # DELETE /composition_items/1.json
  def destroy
    @composition_item.destroy
    if @composition_item.destroyed?
      head :no_content
    else
      render json: @composition_item.errors, status: :unprocessable_content
    end
  end

  private

  # Items of community Compositions have no project.
  def set_composition_item
    @composition_item = CompositionItem
      .where(project_id: [sessions_current_project_id, nil])
      .find(params[:id])
  end

  # Items take their project from their Composition, so it must be one
  # this project can see.
  def check_composition
    if id = params.dig(:composition_item, :composition_id).presence
      Composition.visible_to_project(sessions_current_project_id).find(id)
    end
  end

  # type is set only on create
  def composition_item_params
    params.require(:composition_item).permit(
      :composition_id, :parent_id,
      :composition_item_object_id, :composition_item_object_type,
      :text, :x, :y, :z, :position, :width, :height, :zoom, :rotation_z,
      :svg_view_box, :svg_clip, :opacity, :is_visible, :total, :css_style
    )
  end
end
