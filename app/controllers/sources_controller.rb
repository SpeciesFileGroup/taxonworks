class SourcesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_source, only: [:show, :edit, :update, :destroy, :clone, :api_show]
  after_action -> { set_pagination_headers(:sources) }, only: [:index, :api_index ], if: :json_request?

  # GET /sources
  # GET /sources.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Source.created_this_week.order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @sources = Queries::Source::Filter.new(params).all
        .order(:cached)
        .page(params[:page])
        .per(params[:per])
      }
      format.bib {
        # TODO - handle count and download
        @sources = Queries::Source::Filter.new(params).all
        .order(:cached)
        .page(params[:page])
        .per(params[:per] || 2000)
      }
    end
  end

  def list
    @sources = Source.page(params[:page])
  end

  # GET /sources/1
  # GET /sources/1.json
  def show
  end

  # POST /sources/1/clone.json
  def clone
    respond_to do |format|

      # Don't panic, this `clone` is custom, see source.rb
      @source = @source.clone

      if @source.valid?

        @source.project_sources << ProjectSource.new(project_id: sessions_current_project_id)

        format.html { redirect_to edit_source_path(@source), notice: 'Clone successful, on new record.' }
        format.json { render :show }
      else
        format.html { redirect_to edit_source_path(@source), notice: 'Clone failed.  On original original.' }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /sources/1/edit
  def edit
    redirect_to new_source_task_path(source_id: @source.id), notice: 'Editing in new interface.'
  end

  # GET /sources/new
  def new
    redirect_to new_source_task_path, notice: 'Redirected to new interface.'
  end

  # POST /sources
  # POST /sources.json
  def create
    params[:source].merge!( { project_sources_attributes: [{project_id: sessions_current_project_id}] } )
    @source = new_source

    respond_to do |format|

      if @source && @source.save
        format.html { redirect_to url_for(@source.metamorphosize),
                      notice: "#{@source.type} successfully created." }
        format.json { render action: 'show', status: :created, location: @source.metamorphosize }
      else
        format.html { render action: 'new' }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end

    end
  end

  # GET /sources/select_options
  def select_options
    @sources = Source.select_optimized(sessions_current_user_id, sessions_current_project_id, params[:klass])
  end

  def attributes
    render json: ::Source.columns.select{
      |a| Queries::Source::Filter::ATTRIBUTES.include?(
        a.name.to_sym)
    }.collect{|b| {'name' => b.name, 'type' => b.type } }
  end

  # GET /sources/citation_object_types.json
  def citation_object_types
    render json: Source.joins(:citations)
      .where(citations: {project_id: sessions_current_project_id})
      .select('citations.project_id, citations.citation_object_type')
      .distinct
      .pluck(:citation_object_type).sort
  end

  # GET /sources/csl_types.json
  def csl_types
    render json: ::CSL_STYLES
  end

  def parse
    @source = new_source
    render '/sources/show'
  end

  # PATCH/PUT /sources/1
  # PATCH/PUT /sources/1.json
  def update
    respond_to do |format|
      if @source.update(source_params)
        # We go through this dance to handle changing types from verbatim to other
        @source = @source.becomes!(@source.type.safe_constantize)
        @source.reload # necessary to reload the cached value.
        format.html { redirect_to url_for(@source.metamorphosize), notice: 'Source was successfully updated.' }
        format.json { render :show, status: :ok, location: @source.metamorphosize }
      else
        format.html { render action: 'edit' }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.json
  def destroy
    if @source.destroy
      respond_to do |format|
        format.html { redirect_to sources_url, notice: "Destroyed source #{@source.cached}" }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render action: :show, notice: 'failed to destroy the source, there is likely data associated with it' }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def autocomplete
    @term = params.require(:term)
    @sources = Queries::Source::Autocomplete.new(
      @term,
      **autocomplete_params
    ).autocomplete
  end

  def search
    if params[:id].blank?
      redirect_to sources_path, notice: 'You must select an item from the list with a click or tab ' \
        'press before clicking show.'
    else
      redirect_to source_path(params[:id])
    end
  end

  # GET /sources/batch_load
  def batch_load
  end

  # PATCH /sources/batch_update.json?source_query=<>&serial_id
  def batch_update
    if r = Source::Bibtex.batch_update(
        preview: params[:preview], 
        source: source_params.merge(by: sessions_current_user_id),
        source_query: params[:source_query],
    )
      render json: r.to_json, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def preview_bibtex_batch_load
    file = params.require(:file)
    redirect_to batch_load_sources_path, notice: 'No file has been selected.' and return if file.blank?
    file_ok, mimetype = Utilities::Files.recognized_batch_file_type?(file.tempfile)
    if !file_ok
      redirect_to batch_load_sources_path,
        notice: "File '#{file.original_filename}' is of type '#{mimetype}', and not processable as BibTex."
    else
      @sources, message = Source.batch_preview(file.tempfile)
      if @sources.size > 0
        sha256 = Digest::SHA256.file(file.tempfile)
        cookies[:batch_sources_md5] = sha256.hexdigest
        render 'sources/batch_load/bibtex/bibtex_batch_preview'
      else
        redirect_to batch_load_sources_path,
          notice: "Error parsing BibTeX :#{message}."
      end
    end
  end

  def create_bibtex_batch_load
    file = params.require(:file)
    redirect_to batch_load_sources_path, notice: 'no file has been selected' and return if file.blank?
    sha256 = Digest::SHA256.file(file.tempfile)
    if cookies[:batch_sources_md5] == sha256.hexdigest
      if result_hash = Source.batch_create(file.tempfile, sessions_current_project_id)
        # error in results?
        @count = result_hash[:count]
        @sources = result_hash[:records]
        flash[:notice] = "Successfully batch created #{@count} sources."
        render 'sources/batch_load/bibtex/bibtex_batch_create'
      else
        flash[:notice] = 'Failed to create sources.'
        redirect_to batch_load_sources_path
      end
    else
      flash[:notice] = 'Batch upload must be previewed before it can be created.'
      redirect_to batch_load_sources_path
    end
  end

  # GET /sources/download
  def download
    send_data Export::CSV.generate_csv(
      Source.joins(:project_sources)
      .where(project_sources: {project_id: sessions_current_project_id})
      .all),
    type: 'text', filename: "sources_#{DateTime.now}.tsv"
  end

  # GET /sources/generate.json?<filter params>
  def generate
    sources = Queries::Source::Filter.new(params).all.page(params[:page]).per(params[:per] || 2000)
    @download = ::Export::Bibtex.download(
      sources,
      request.url,
      (params[:is_public] == 'true' ? true : false),
      params[:style_id]
    )
    render '/downloads/show'
  end

  # GET /sources/generate.json?<filter params>
  def download_formatted
    params.require(:style_id)
    @sources = Queries::Source::Filter.new(params).all
      .order(:cached)

    f = render_to_string(:index, formats: [:bib])

    respond_to do |format|
      format.pdf do
        pdf = ::Prawn::Document.new
        pdf.text(f, inline_format: true) # Formats <i>

        send_data(pdf.render, filename: "tw_bibliography_#{DateTime.now}.pdf", type: 'application/pdf')
      end

      format.json do
        send_data(f, filename: "tw_bibliography_#{DateTime.now}.txt", type: 'text/plain')
      end 
    end
  end

  # GET /api/v1/sources
  def api_index
    @sources = Queries::Source::Filter.new(params.merge!(api: true)).all
      .order('sources.id')
      .page(params[:page]).per(params[:per])
    render '/sources/api/v1/index'
  end

  # GET /api/v1/sources/:id
  def api_show
    render '/sources/api/v1/show'
  end

  private

  def new_source
    if params[:bibtex_input].blank?
      Source.new(source_params)
    else
      Source::Bibtex.new_from_bibtex_text(params[:bibtex_input])
    end
  end

  def autocomplete_params
    params.permit(:limit_to_project).merge(project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  def set_source
    @source = Source.find(params[:id])
    @recent_object = @source
  end

  def batch_params
  end

  def source_params
    params.require(:source).permit(
      :serial_id, :address, :annote, :author, :booktitle, :chapter,
      :crossref, :edition, :editor, :howpublished, :institution,
      :journal, :key, :month, :note, :number, :organization, :pages,
      :publisher, :school, :series, :title, :type, :volume, :doi,
      :abstract, :copyright, :language, :stated_year, :verbatim,
      :bibtex_type, :day, :year, :isbn, :issn, :verbatim_contents,
      :verbatim_keywords, :language_id, :translator, :year_suffix, :url, :type, :style_id,
      :convert_to_bibtex,
      project_sources_attributes: [:project_id],
      roles_attributes: [
        :id,
        :_destroy,
        :type,
        :person_id,
        :position,
        person_attributes: [
          :last_name, :first_name, :suffix, :prefix
        ]
      ]
    )
  end
end
