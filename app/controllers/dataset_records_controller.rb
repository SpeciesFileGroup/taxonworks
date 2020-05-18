class DatasetRecordsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_dataset_record, only: [:show, :edit, :update, :destroy]
  after_action -> { set_pagination_headers(:dataset_records) }, only: [:index], if: :json_request?

  # GET /dataset_records
  # GET /dataset_records.json
  def index
    @dataset_records = ImportDataset.find(params[:import_dataset_id]).dataset_records.page(params[:page]).per(params[:per] || 100)

    params[:filter]&.each do |k, v|
      @dataset_records = @dataset_records.where("data_fields -> ? ->> 'value' = ?", k, v)
    end
  end

  # GET /dataset_records/1
  # GET /dataset_records/1.json
  def show
  end

  # GET /dataset_records/new
  def new
    @dataset_record = DatasetRecord.new
  end

  # GET /dataset_records/1/edit
  def edit
  end

  # POST /dataset_records
  # POST /dataset_records.json
  def create
    @dataset_record = DatasetRecord.new(dataset_record_params)

    respond_to do |format|
      if @dataset_record.save
        format.html { redirect_to @dataset_record, notice: 'Dataset record was successfully created.' }
        format.json { render :show, status: :created, location: @dataset_record }
      else
        format.html { render :new }
        format.json { render json: @dataset_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dataset_records/1
  # PATCH/PUT /dataset_records/1.json
  def update
    respond_to do |format|

      JSON.parse(params[:data_fields]).each { |f, v| @dataset_record.set_data_field(f, v) }

      if @dataset_record.save
        format.html { redirect_to @dataset_record, notice: 'Dataset record was successfully updated.' }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @dataset_record.errors, status: :unprocessable_entity }
      end
    end
  end

  def autocomplete_data_fields
    render json: {} and return if params[:field].blank? || params[:value].blank?

    values = ImportDataset.find(params[:import_dataset_id])
      .dataset_records.where("data_fields -> ? ->> 'value' ILIKE '#{params[:value]}%'", params[:field])
      .select("data_fields -> '#{params[:field]}' ->> 'value' AS value").distinct # TODO: Sanitize field
      .page(params[:page]).per(params[:per] || 10)
      .map { |x| x.value }

    render json: values, status: :ok
  end

  # DELETE /dataset_records/1
  # DELETE /dataset_records/1.json
  def destroy
    @dataset_record.destroy
    respond_to do |format|
      format.html { redirect_to dataset_records_url, notice: 'Dataset record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dataset_record
      @dataset_record = DatasetRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dataset_record_params
      params.require(:dataset_record).permit(:data_fields)
    end
end
