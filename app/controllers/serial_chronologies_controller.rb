class SerialChronologiesController < ApplicationController
  include DataControllerConfiguration

  before_action :require_sign_in
  before_action :set_serial_chronology, only: [:show, :edit, :update, :destroy]

  # GET /serial_chronologies
  # GET /serial_chronologies.json
  def index
    @serial_chronologies = SerialChronology.all
  end

  # GET /serial_chronologies/1
  # GET /serial_chronologies/1.json
  def show
  end

  # GET /serial_chronologies/new
  def new
    @serial_chronology = SerialChronology.new
  end

  # GET /serial_chronologies/1/edit
  def edit
  end

  # POST /serial_chronologies
  # POST /serial_chronologies.json
  def create
    @serial_chronology = SerialChronology.new(serial_chronology_params)

    respond_to do |format|
      if @serial_chronology.save
        format.html { redirect_to @serial_chronology, notice: 'Serial chronology was successfully created.' }
        format.json { render action: 'show', status: :created, location: @serial_chronology }
      else
        format.html { render action: 'new' }
        format.json { render json: @serial_chronology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /serial_chronologies/1
  # PATCH/PUT /serial_chronologies/1.json
  def update
    respond_to do |format|
      if @serial_chronology.update(serial_chronology_params)
        format.html { redirect_to @serial_chronology, notice: 'Serial chronology was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @serial_chronology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /serial_chronologies/1
  # DELETE /serial_chronologies/1.json
  def destroy
    @serial_chronology.destroy
    respond_to do |format|
      format.html { redirect_to serial_chronologies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_serial_chronology
      @serial_chronology = SerialChronology.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def serial_chronology_params
      params.require(:serial_chronology).permit(:preceding_serial_id, :succeeding_serial_id)
    end
end
