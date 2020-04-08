class DatasetRecordsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_dataset_record, only: [:show, :edit, :update, :destroy]
  after_action -> { set_pagination_headers(:dataset_records) }, only: [:index], if: :json_request?

  # GET /dataset_records
  # GET /dataset_records.json
  def index
    @dataset_records = ImportDataset.find(params[:import_dataset_id]).dataset_records.page(params[:page]).per(params[:per] || 100)
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
      if @dataset_record.update(dataset_record_params)
        format.html { redirect_to @dataset_record, notice: 'Dataset record was successfully updated.' }
        format.json { render :show, status: :ok, location: @dataset_record }
      else
        format.html { render :edit }
        format.json { render json: @dataset_record.errors, status: :unprocessable_entity }
      end
    end
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
