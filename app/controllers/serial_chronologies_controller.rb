class SerialChronologiesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :require_sign_in
  before_action :set_serial_chronology, only: [:update, :destroy]

  # POST /serial_chronologies
  # POST /serial_chronologies.json
  def create
    @serial_chronology = SerialChronology.new(serial_chronology_params)

    respond_to do |format|
      if @serial_chronology.save
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Serial chronology was successfully created.')}
        format.json {render json: @serial_chronology, status: :created, location: @serial_chronology}
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Serial chronology was NOT successfully created.')}
        format.json {render json: @serial_chronology.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /serial_chronologies/1
  # PATCH/PUT /serial_chronologies/1.json
  def update
    respond_to do |format|
      if @serial_chronology.update(serial_chronology_params)
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Serial chronology was successfully updated.')}
        format.json {head :no_content}
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Serial chronology was NOT successfully updated.')}
        format.json {render json: @serial_chronology.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /serial_chronologies/1
  # DELETE /serial_chronologies/1.json
  def destroy
    @serial_chronology.destroy
    respond_to do |format|
      format.html { destroy_redirect @serial_chronology, notice: 'Serial chronology was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_serial_chronology
    @serial_chronology = SerialChronology.find(params[:id])
    @recent_object = @serial_chronology
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def serial_chronology_params
    params.require(:serial_chronology).permit(:preceding_serial_id, :succeeding_serial_id, :type)
  end
end
