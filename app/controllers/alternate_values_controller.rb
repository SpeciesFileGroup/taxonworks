class AlternateValuesController < ApplicationController
  include DataControllerConfiguration

  before_action :set_alternate_value, only: [:show, :edit, :update, :destroy]

  # GET /alternate_values
  # GET /alternate_values.json
  def index
    @alternate_values = AlternateValue.all
  end

  # GET /alternate_values/1
  # GET /alternate_values/1.json
  def show
  end

  # GET /alternate_values/new
  def new
    @alternate_value = AlternateValue.new
  end

  # GET /alternate_values/1/edit
  def edit
  end

  # POST /alternate_values
  # POST /alternate_values.json
  def create
    @alternate_value = AlternateValue.new(alternate_value_params)

    respond_to do |format|
      if @alternate_value.save
        format.html { redirect_to @alternate_value.becomes(AlternateValue), notice: 'Alternate value was successfully created.' }
        format.json { render action: 'show', status: :created, location: @alternate_value }
      else
        format.html { render action: 'new' }
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alternate_values/1
  # PATCH/PUT /alternate_values/1.json
  def update
    respond_to do |format|
      if @alternate_value.update(alternate_value_params)
        format.html { redirect_to @alternate_value.becomes(AlternateValue), notice: 'Alternate value was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @alternate_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alternate_values/1
  # DELETE /alternate_values/1.json
  def destroy
    @alternate_value.destroy
    respond_to do |format|
      format.html { redirect_to alternate_values_url }
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
