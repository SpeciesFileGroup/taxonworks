class DatasetRecordsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  include ZipTricks::RailsStreaming

  before_action :set_dataset_record, only: [:show, :update, :destroy]
  after_action -> { set_pagination_headers(:dataset_records) }, only: [:index], if: :json_request?

  # GET /dataset_records
  # GET /dataset_records.json
  def index
    respond_to do |format|
      format.json { @dataset_records = filtered_records.order(id: :asc).page(params[:page]).per(params[:per] || 100) } #.preload_fields
      format.zip { render_zip }
    end
  end

  # GET /dataset_records/1
  # GET /dataset_records/1.json
  def show
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

      JSON.parse(params[:data_fields]).each { |index, value| @dataset_record.set_data_field(index.to_i, value) }

      if @dataset_record.save
        format.json { render :show, status: :ok }
      else
        format.json { render json: @dataset_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dataset_records/set_field_value
  def set_field_value
    filtered_records.find_each(batch_size: 10000) do |record| #.preload_fields
      record.set_data_field(Integer(params[:field]), params[:value])
      record.save!
    end unless params[:filter].blank?

    render json: true, status: :ok
  end

  def autocomplete_data_fields
    render json: {} and return if params[:field].blank? || params[:value].blank?

    import_dataset = ImportDataset.where(project_id: sessions_current_project_id).find(params[:import_dataset_id])

    values = import_dataset.core_records_fields.where(dataset_record: filtered_records)
      .at(params[:field].to_i).with_prefix_value(params[:value])
      .select(:value).distinct
      .page(params[:page]).per(params[:per] || 10)
      .map { |f| f.value }

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
      @dataset_record = DatasetRecord.where(
        project_id: sessions_current_project_id,
        import_dataset_id: params[:import_dataset_id]
      ).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dataset_record_params
      params.require(:dataset_record).permit(data_fields: {})
    end

    def import_dataset
      ImportDataset.where(project_id: sessions_current_project_id).find(params[:import_dataset_id])
    end

    def filtered_records
      dataset_records = import_dataset.core_records
      params[:filter]&.each do |key, value|
        dataset_records = dataset_records.where(
          id: import_dataset.core_records_fields.at(key.to_i).with_value(value).select(:dataset_record_id)
        )
      end

      params[:status].blank? ? dataset_records : dataset_records.where(status: params[:status])
    end

    def render_zip
      response.headers[Rack::ETAG] = SecureRandom.hex # Prevents Rack::ETAG from buffering the response

      filename = Zaru::sanitize!("#{import_dataset.description}_#{DateTime.now}.tsv").gsub(' ', '_').downcase
      headers = import_dataset.metadata["core_headers"]

      response.headers["Content-Disposition"] = "attachment; filename=\"#{filename}.zip\""

      zip_tricks_stream do |zip|
        zip.write_deflated_file('filters.txt') do |sink|
          sink.write "Status: #{params[:status] || 'Any'}\n---\n"
          params[:filter].each {|k, v| sink.write("#{headers[k.to_i]}: #{v}\n") } if params[:filter]
        end

        zip.write_deflated_file(filename) do |sink|
          sink.write CSV.generate_line([
            'Status', 'error_data', *headers
          ], col_sep: "\t", quote_char: '')

          filtered_records.find_each do |row|
            sink.write CSV.generate_line([
              row.status, row.metadata&.dig('error_data', 'messages'), *row.data_fields
            ], col_sep: "\t", quote_char: '')
          end
        end
      end
    end

 end
