class DataAttributesController < ApplicationController
  include DataControllerConfiguration

  before_action :set_data_attribute, only: [:update, :destroy]

  # GET /data_attributes
  # GET /data_attributes.json
  def index
    @data_attributes = DataAttribute.all
  end

  # # GET /data_attributes/new
  # def new
  #   @data_attribute = DataAttribute.new
  # end
  #
  # # GET /data_attributes/1/edit
  # def edit
  # end

  # POST /data_attributes
  # POST /data_attributes.json
  def create
    @data_attribute = DataAttribute.new(data_attribute_params)

    respond_to do |format|
      if @data_attribute.save
        format.html { redirect_to :back, notice: 'Data attribute was successfully created.' }
        format.json { render json: @data_attribute, status: :created, location: @data_attribute }
      else
        format.html { redirect_to :back, notice: 'Data attribute was NOT successfully created.' }
        format.json { render json: @data_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_attributes/1
  # PATCH/PUT /data_attributes/1.json
  def update
    respond_to do |format|
      if @data_attribute.update(data_attribute_params)
        format.html { redirect_to :back, notice: 'Data attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Data attribute was NOT successfully updated.' }
        format.json { render json: @data_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_attributes/1
  # DELETE /data_attributes/1.json
  def destroy
    @data_attribute.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Data attribute was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_data_attribute
    @data_attribute = DataAttribute.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def data_attribute_params
    params.require(:data_attribute).permit(:type, :attribute_subject_id, :attribute_subject_type,
                                           :controlled_vocabulary_term, :import_predicate,
                                           :value)
  end
end
