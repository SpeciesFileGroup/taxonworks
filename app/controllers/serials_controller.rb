class SerialsController < ApplicationController
  include DataControllerConfiguration

  before_action :require_sign_in
  before_action :set_serial, only: [:show, :edit, :update, :destroy]

  # GET /serials
  # GET /serials.json
  def index
    @serials = Serial.all
  end

  # GET /serials/1
  # GET /serials/1.json
  def show
  end

  # GET /serials/new
  def new
    @serial = Serial.new
  end

  # GET /serials/1/edit
  def edit
  end

  # POST /serials
  # POST /serials.json
  def create
    @serial = Serial.new(serial_params)

    respond_to do |format|
      if @serial.save
        format.html { redirect_to @serial, notice: 'Serial was successfully created.' }
        format.json { render action: 'show', status: :created, location: @serial }
      else
        format.html { render action: 'new' }
        format.json { render json: @serial.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /serials/1
  # PATCH/PUT /serials/1.json
  def update
    respond_to do |format|
      if @serial.update(serial_params)
        format.html { redirect_to @serial, notice: 'Serial was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @serial.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /serials/1
  # DELETE /serials/1.json
  def destroy
    @serial.destroy
    respond_to do |format|
      format.html { redirect_to serials_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_serial
      @serial = Serial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def serial_params
      params.require(:serial).permit(:name, :created_by_id, :updated_by_id, :project_id, :publisher, :place_published, :primary_language_id, :first_year_of_issue, :last_year_of_issue)
    end
end
