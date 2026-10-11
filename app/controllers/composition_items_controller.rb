class CompositionItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_composition_item,
    only: [:show, :update, :destroy, :ungroup]

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
        type: params.dig(:composition_item, :type),
        composition_id: params.dig(:composition_item, :composition_id)
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

  # POST /composition_items/1/ungroup.json
  # Removes a LayoutItem::GroupItem, keeping its members in place.
  # Renders the former members.
  def ungroup
    if !@composition_item.is_a?(LayoutItem::GroupItem)
      render json: { base: ['only a group can be ungrouped'] },
        status: :unprocessable_content
      return
    end
    @composition_items = @composition_item.ungroup!
    render :index
  end

  private

  # Items of community Compositions have no project. A nil project_id alone
  # isn't trusted (items' project is only kept in step by callbacks), the
  # Composition must be community (enforced by a DB check constraint).
  def set_composition_item
    @composition_item = CompositionItem
      .where(project_id: sessions_current_project_id)
      .or(CompositionItem.where(
        composition_id: Composition.where(is_community: true).select(:id)
      ))
      .find(params[:id])
  end

  # type and composition_id are set only on create
  def composition_item_params
    params.require(:composition_item).permit(
      :parent_id,
      :composition_item_object_id, :composition_item_object_type,
      :text, :x, :y, :z, :position, :width, :height, :zoom, :rotation_z,
      :svg_view_box, :svg_clip, :opacity, :is_visible, :total, :css_style
    )
  end
end
