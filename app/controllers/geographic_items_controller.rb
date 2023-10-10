class GeographicItemsController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_geographic_item, only: [:show, :edit, :update]
  before_action :require_administrator_sign_in, only: [:update, :edit]

  # GET /geographic_items/1
  # GET /geographic_items/1.json
  # GET /geographic_items/1.wkt
  def show
    respond_to do |format|
      format.html {}
      format.json {}
      format.wkt {
        render plain: @geographic_item.to_wkt, layout: false
      }
      format.geojson {
        render json: @geographic_item.to_geo_json, layout: false
      }
    end

  end

  # GET /geographic_items/1/edit
  def edit
  end

  # PATCH/PUT /geographic_items/1
  # PATCH/PUT /geographic_items/1.json
  def update
    respond_to do |format|
      if @geographic_item.update(geographic_item_params)
        format.html { redirect_to @geographic_item.metamorphosize, notice: 'Geographic item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @geographic_item.errors, status: :unprocessable_entity }
      end
    end
  end

# # DELETE /geographic_items/1
# # DELETE /geographic_items/1.json
# def destroy
#   @geographic_item.destroy
#   respond_to do |format|
#     format.html { redirect_to geographic_items_url }
#     format.json { head :no_content }
#   end
# end

  private

  def set_geographic_item
    @geographic_item = GeographicItem.find(params[:id])
    @recent_object = @geographic_item
  end

  def geographic_item_params
    params.require(:geographic_item).permit(
      :point,
      :line_string,
      :polygon,
      :multi_point,
      :multi_line_string,
      :multi_polygon,
      :geometry_collection,
      :shape
    )
  end
end
