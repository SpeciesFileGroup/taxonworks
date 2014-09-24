class PinboardItemsController < ApplicationController
  before_action :set_pinboard_item, only: [:destroy]

  # POST /pinboard_items
  # POST /pinboard_items.json
  def create
    @pinboard_item = PinboardItem.new(pinboard_item_params.merge(user_id: sessions_current_user_id))
    respond_to do |format|
      if @pinboard_item.save
        format.html { redirect_to :back, notice: 'Pinboard item was successfully created.' }
        format.json { render json: @pinboard_item, status: :created, location: @pinboard_item }
      else
        format.html { redirect_to :back, notice: "Couldn't pin this item! Is it already there?" }
        format.json { render json: @pinboard_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # Need update to order

  # DELETE /pinboard_items/1
  # DELETE /pinboard_items/1.json
  def destroy
    @pinboard_item.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Pinboard item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_pinboard_item
    @pinboard_item = PinboardItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pinboard_item_params
    params.require(:pinboard_item).permit(:pinned_object_id, :pinned_object_type, :user_id, :is_inserted, :is_cross_project, :inserted_count)
  end
end
