class SerialsController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :require_sign_in
  before_action :set_serial, only: [:show, :edit, :update, :destroy]

  # GET /serials
  # GET /serials.json

  def index
    respond_to do |format|
      format.html do
        @recent_objects = Serial.order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        #@serials = Serial.order(updated_at: :desc).limit(10)
        @serials = Queries::Serial::Filter.new(filter_params).all
        .page(params[:page])
        .per(params[:per])
      }
    end
  end

  def list
    @serials = Serial.order(:id).page(params[:page])
  end

  # GET /serials/1
  # GET /serials/1.json
  def show
    # TODO: put computation here for displaying alternate values?
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
        format.html { redirect_to @serial, notice: "Serial '#{@serial.name}' was successfully created." }
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
      if @serial.destroyed?
        format.html { redirect_to serials_url }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @serial, notice: 'Serial was not destroyed, ' + @serial.errors.full_messages.join('; ') }
        format.json { render json: @serial.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:id].blank?
      redirect_to serials_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to serial_path(params[:id])
    end
  end

  # GET /serials/autocomplete
  def autocomplete
    render json: {} and return if params[:term].blank?

    @serials = Queries::Serial::Autocomplete.new(
      params[:term],
      **autocomplete_params
    ).autocomplete
  end

  # GET /serials/select_options.json
  def select_options
    @serials = Serial.select_optimized(sessions_current_user_id, sessions_current_project_id)
  end

  # GET /serials/download
  def download
    send_data(
      Export::Download.generate_csv(Serial.all),
      type: 'text',
      filename: "serials_#{DateTime.now}.csv")
  end

  private

  def filter_params
    f = ::Queries::Serial::Filter.permit(params)
  end

  def set_serial
    @serial = Serial.find(params[:id])
    @recent_object = @serial
  end

  def autocomplete_params
    params.permit(:limit_to_project).merge(project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  def serial_params
    params.require(:serial).permit(
      :name,
      :publisher,
      :place_published,
      :primary_language_id,
      :first_year_of_issue,
      :last_year_of_issue,
      :translated_from_serial_id,
      :is_electronic_only,
      alternate_values_attributes: [
        :id,
        :value,
        :type,
        :language_id,
        :alternate_value_object_type,
        :alternate_value_object_id,
        :alternate_value_object_attribute,
        :_destroy
      ])
  end
end
