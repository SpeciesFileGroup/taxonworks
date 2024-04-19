class ObservationMatricesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_observation_matrix, only: [
    :show, :api_show, :edit, :update, :destroy,
    :nexml, :tnt, :nexus, :csv, :otu_content, :descriptor_list,
    :reorder_rows, :reorder_columns, :row_labels, :column_labels]
  after_action -> { set_pagination_headers(:observation_matrices) }, only: [:index, :api_index], if: :json_request?

  # GET /observation_matrices
  # GET /observation_matrices.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = ObservationMatrix.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @observation_matrices = ::Queries::ObservationMatrix::Filter.new(params).all
          .where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /observation_matrices/1
  # GET /observation_matrices/1.json
  def show
  end

  def list
    @observation_matrices = ObservationMatrix.with_project_id(sessions_current_project_id).page(params[:page]).per(params[:per])
  end

  # GET /observation_matrices/new
  def new
    redirect_to new_matrix_task_path, notice: 'Redirecting to new task.'
  end

  # GET /observation_matrices/1/edit
  def edit
  end

  # POST /observation_matrices
  # POST /observation_matrices.json
  def create
    @observation_matrix = ObservationMatrix.new(observation_matrix_params)

    respond_to do |format|
      if @observation_matrix.save
        format.html { redirect_to @observation_matrix, notice: 'Matrix was successfully created.' }
        format.json { render :show, status: :created, location: @observation_matrix }
      else
        format.html { render :new }
        format.json { render json: @observation_matrix.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observation_matrices/1
  # PATCH/PUT /observation_matrices/1.json
  def update
    respond_to do |format|
      if @observation_matrix.update(observation_matrix_params)
        format.html { redirect_to @observation_matrix, notice: 'Matrix was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation_matrix }
      else
        format.html { render :edit }
        format.json { render json: @observation_matrix.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observation_matrices/1
  # DELETE /observation_matrices/1.json
  def destroy
    @observation_matrix.destroy
    respond_to do |format|
      format.html { redirect_to observation_matrices_url, notice: 'Matrix was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # .json
  def batch_create
    o = ObservationMatrix.batch_create(params.merge(project_id: sessions_current_project_id))
    if o.kind_of?(Hash)
      render json: o
    else
      render json: o, status: :unprocessable_entity
    end
  end

  # .json
  def batch_add
    o = ObservationMatrix.batch_add(params.merge(project_id: sessions_current_project_id))
    if o.kind_of?(Hash)
      render json: o
    else
      render json: o, status: :unprocessable_entity
    end
  end

  def reorder_rows
    if @observation_matrix.reorder_rows(params.require(:by))
      render json: :success
    else
      render json:  :error, status: :unprocessable_entity
    end
  end

  def reorder_columns
    @observation_matrix.reorder_columns(params.require(:by))
  end

  def autocomplete
    @observation_matrices = ObservationMatrix.where(project_id: sessions_current_project_id).where('name ilike ?', "%#{params[:term]}%")
  end

  # TODO: deprecate
  def search
    if params[:id].blank?
      redirect_to observation_matrices_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to observation_matrix_path(params[:id])
    end
  end

  def row_labels
  end

  def column_labels
  end

  # TODO export formats can move to a concern controller

  def nexml
    @options = nexml_params
    respond_to do |format|
      base =  '/observation_matrices/export/nexml/'
      format.html { render base + 'index' }
      format.rdf {
        s = render_to_string(partial: base + 'nexml', layout: false, formats: [:rdf])
        send_data(s, filename: "nexml_#{DateTime.now}.xml", type: 'text/plain')
      }
    end
  end

  def otu_content
    @options = otu_content_params
    respond_to do |format|
      base ='/observation_matrices/export/otu_content/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'otu_content', layout: false, formats: [:html])
        send_data(s, filename: "otu_content_#{DateTime.now}.csv", type: 'text/plain')
      }
    end
  end

  def descriptor_list
    respond_to do |format|
      base = '/observation_matrices/export/descriptor_list/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'descriptor_list', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "descriptor_list_#{DateTime.now}.csv", type: 'text/plain')
      }
    end
  end

  def tnt
    respond_to do |format|
      base = '/observation_matrices/export/tnt/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'tnt', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "tnt_#{DateTime.now}.tnt", type: 'text/plain')
      }
    end
  end

  def csv
    respond_to do |format|
      base = '/observation_matrices/export/csv/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'csv', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "csv_#{DateTime.now}.csv", type: 'text/plain')
      }
    end
  end

  def nexus
    respond_to do |format|
      base = '/observation_matrices/export/nexus/'
      format.html { render base + 'index' }
      format.text {
        s = render_to_string(partial: base + 'nexus', locals: { as_file: true }, layout: false, formats: [:html])
        send_data(s, filename: "nexus_#{DateTime.now}.nex", type: 'text/plain')
      }
    end
  end

  # GET /observation_matrices/row.json?observation_matrix_row_id=1
  # TODO: Why is this here? (used in Matrix Row Coder)
  def row
    @observation_matrix_row = ObservationMatrixRow.where(project_id: sessions_current_project_id).find(params.require(:observation_matrix_row_id))
  end

  def column
    @observation_matrix_column = ObservationMatrixColumn.where(project_id: sessions_current_project_id).find(params.require(:observation_matrix_column_id))
  end

  def download
    send_data Export::CSV.generate_csv(ObservationMatrix.where(project_id: sessions_current_project_id)), type: 'text', filename: "observation_matrices_#{DateTime.now}.tsv"
  end

  def download_contents
    send_data Export::CSV.generate_csv(ObservationMatrix.where(project_id: sessions_current_project_id)), type: 'text', filename: "observation_matrices_#{DateTime.now}.csv"
  end

  def otus_used_in_matrices
    # ObservationMatrix.with_otu_ids_array([13597, 25680])
    if params[:otu_ids].present?
      p = ObservationMatrix.with_otu_id_array(params[:otu_ids].split('|')).pluck(:id)
      if p.nil?
        render json: {otus_used_in_matrices: ''}.to_json
      else
        render json: {otus_used_in_matrices: p}.to_json
      end
    else
      render json: {otus_used_in_matrices: ''}.to_json
    end
  end

  # GET /api/v1/observation_matrices
  def api_index
    @observation_matrices = Queries::ObservationMatrix::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])
    render '/observation_matrices/api/v1/index'
  end

  # GET /api/v1/observation_matrices/:id
  def api_show
    render '/observation_matrices/api/v1/show'
  end

  # GET /observation_matrices/nexus_data.json
  def nexus_data
    return if !(nf = document_to_nexus(params[:nexus_document_id]))

    options = nexus_import_options_params

    @otus = helpers.preview_nexus_otus(nf,
      options[:match_otu_to_name], options[:match_otu_to_taxonomy_name])

    @descriptors = helpers.preview_nexus_descriptors(nf,
      options[:match_character_to_name])
  end

  # POST /observation_matrices/import_nexus.json
  def import_from_nexus
    return if !(nf = document_to_nexus params[:nexus_document_id])

    options = nexus_import_options_params

    return if !(m = create_matrix_for_nexus_import(options[:matrix_name]))

    # Once we've handed the matrix off to the background job it could get
    # destroyed at any time, so save what we want from it now.
    matrix_id = m.id
    matrix_name = m.name

    #ImportNexusJob.perform_later(
    helpers.create_matrix_from_nexus(
      params[:nexus_document_id],
      nf,
      m,
      sessions_current_user_id,
      sessions_current_project_id,
      options
    )

    render json: { matrix_id:, matrix_name: }
  end

  private

  # TODO: Not all params are supported yet.
  def nexml_params
    { observation_matrix: @observation_matrix,
      target: '',
      include_otus: 'true',
      include_collection_objects: 'true',
      include_descriptors: 'true',
      include_otu_depictions: 'true',
      include_matrix: 'true',
      include_trees: 'false',
      rdf: false }.merge!(
        params.permit(
          :include_otus,
          :include_collection_objects,
          :include_descriptors,
          :include_matrix,
          :include_trees,
          :rdf
        ).to_h
      )
  end

  def otu_content_params
    { observation_matrix: @observation_matrix,
      target: '',
      include_otus: 'true',
      include_collection_objects: 'false',
      include_contents: 'true',
      include_distribution: 'true',
      include_type: 'true',
      taxon_name: 'true',
      include_nomenclature: 'true',
      include_autogenerated_description: 'true',
      include_depictions: 'true',
      rdf: false }.merge!(
        params.permit(
          :include_otus,
          :include_collection_objects,
          :include_matrix,
          :include_contents,
          :include_distribution,
          :include_type,
          :taxon_name,
          :include_nomenclature,
          :include_autogenerated_description,
          :include_depictions,
          :rdf
        ).to_h
      )
  end

  def set_observation_matrix
    @observation_matrix = ObservationMatrix.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def observation_matrix_params
    params.require(:observation_matrix).permit(:name)
  end

  def nexus_import_options_params
    boolean_options = [:match_otu_to_taxonomy_name, :match_otu_to_name,
      :match_character_to_name]

    params[:options].each { |k, v|
      if boolean_options.include? k.to_sym
        params[:options][k] = (v == 'true' || v == true) ? true : false
      end
    }

    params.require(:options).permit(:matrix_name, *boolean_options)
  end

  def document_to_nexus(doc_id)
    begin
      Vendor::NexusParser.document_id_to_nexus(doc_id)
    rescue ActiveRecord::RecordNotFound, NexusParser::ParseError => e
      render json: { errors: "Nexus parse error: #{e}" },
        status: :unprocessable_entity
      return nil
    end
  end

  # @return [Matrix, nil]
  def create_matrix_for_nexus_import(matrix_name)
    if matrix_name.present?
      begin
        m = ObservationMatrix.create!(name: matrix_name)
      rescue ActiveRecord::RecordInvalid
        render json: { errors: 'The provided matrix name is already in use, try another' },
          status: unprocessable_entity
      end

      return m
    end

    i = 0
    unique = ''
    begin
      title = matrix_name.presence ||
        "Converted matrix created #{Time.now.utc.to_formatted_s(:long)} by #{User.find(Current.user_id).name + unique}"

      m = ObservationMatrix.create!(name: title)
    rescue ActiveRecord::RecordInvalid
      if i < 10
        i = i + 1
        unique = "-#{i}"
        retry
      end
    end

    m
  end

end