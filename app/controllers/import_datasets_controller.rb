class ImportDatasetsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_import_dataset, only: [:show, :import, :stop_import, :edit, :update, :destroy]

  # GET /import_datasets
  # GET /import_datasets.json
  def index
    @recent_objects = ImportDataset.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10).map { |i| i.becomes(ImportDataset) }
    render '/shared/data/all/index'
  end

  # GET /import_datasets/1
  # GET /import_datasets/1.json
  def show
  end

  # POST /import_datasets/1/import.json
  def import
    params.permit(:record_id, :retry_errored, filter: {})

    @filters = params[:filter]
    @results = @import_dataset.import(5000, 100,
      retry_errored: params[:retry_errored],
      filters: params[:filter],
      record_id: params[:record_id]
    )
  end

  # POST /import_datasets/1/stop_import.json
  def stop_import
    params.permit(:record_id, :retry_errored, filter: {})

    @filters = params[:filter]
    @import_dataset.stop_import
  end

  # GET /import_datasets/new
  def new
    @import_dataset = ImportDataset.new
  end

  # GET /import_datasets/1/edit
  def edit
  end

  # POST /import_datasets
  # POST /import_datasets.json
  def create
    # TODO: Must not default to DwC-A dataset.
    @import_dataset = ImportDataset::DarwinCore.create_with_subtype_detection(import_dataset_params)

    respond_to do |format|
      if @import_dataset.save
        format.html { redirect_to @import_dataset.becomes(ImportDataset), notice: 'Import dataset was successfully created.' }
        format.json { render :show, status: :created, location: @import_dataset.becomes(ImportDataset) }
      else
        format.html { render :new }
        format.json { render json: @import_dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /import_datasets/1
  # PATCH/PUT /import_datasets/1.json
  def update
    respond_to do |format|
      if @import_dataset.update(import_dataset_params)
        format.html { redirect_to @import_dataset.becomes(ImportDataset), notice: 'Import dataset was successfully updated.' }
        format.json { render :show, status: :ok, location: @import_dataset.becomes(ImportDataset) }
      else
        format.html { render :edit }
        format.json { render json: @import_dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /import_datasets/1
  # DELETE /import_datasets/1.json
  def destroy
    ImportDataset.transaction do
      @import_dataset.destroy
    end
    respond_to do |format|
      format.html { redirect_to import_datasets_url, notice: 'Import dataset was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @import_datasets = ImportDataset.with_project_id(sessions_current_project_id).order(:id).page(params[:page])
  end

  private
  def set_import_dataset
    @import_dataset = ImportDataset.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def import_dataset_params
    params.require(:import_dataset).permit(
      :source,
      :description,
      import_settings: [
        :nomenclatural_code,
        :row_type,
        :col_sep,
        :quote_char
      ])
  end
end
