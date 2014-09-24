class AlternateValuesController < ApplicationController
  include DataControllerConfiguration

  before_action :set_alternate_value, only: [:update, :destroy] # :edit removed from this list

  # POST /alternate_values
  # POST /alternate_values.json
  def create
    @alternate_value = AlternateValue.new(alternate_value_params)

    respond_to do |format|
      if @alternate_value.save
        format.html { redirect_to :back, notice: 'Alternate value was successfully created.' }
        format.json { render json: @alternate_value, status: :created, location: @alternate_value }
      else
        format.html { redirect_to :back, notice: 'Alternate value was NOT successfully created.' }
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alternate_values/1
  # PATCH/PUT /alternate_values/1.json
  def update
    respond_to do |format|
      if @alternate_value.update(alternate_value_params)
        format.html { redirect_to :back, notice: 'Alternate value was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Alternate value was NOT successfully updated.' }
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alternate_values/1
  # DELETE /alternate_values/1.json
  def destroy
    @alternate_value.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Alternate value was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_alternate_value
    @alternate_value = AlternateValue.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def alternate_value_params
    params.require(:alternate_value).permit(:value, :type, :language_id, :alternate_object_type, :alternate_object_id, :alternate_object_attribute)
  end
end
