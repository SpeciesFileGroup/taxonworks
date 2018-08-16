class SourcesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_source, only: [:show, :edit, :update, :destroy]

  # GET /sources
  # GET /sources.json
  def index
    @recent_objects = Source.created_this_week.order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  def list
    @sources = Source.page(params[:page])
  end

  # GET /sources/1
  # GET /sources/1.json
  def show
  end

  # GET /sources/new
  def new
    @source = Source.new
  end

  # GET /sources/1/edit
  def edit
  end

  # POST /sources
  # POST /sources.json
  # TODO: move all the logic to model(s)
  def create
    @source = new_source 
    respond_to do |format|
      if @source.save
        format.html { redirect_to url_for(@source.metamorphosize),
                      notice: "#{@source.type} successfully created." }
        format.json { render action: 'show', status: :created, location: @source.metamorphosize }
      else
        format.html { render action: 'new' }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_source
    if params[:bibtex_input].blank?
      Source.new(source_params)
    else
      Source::Bibtex.new_from_bibtex_text(params[:bibtex_input])
    end
  end

  def parse
    if @source = new_source
      render '/sources/show'
    else
      render json: {status: :failed}
    end
    #   bibtex_string = params['bibtex_input']
    #   
    #   begin
    #     a = BibTeX.parse(bibtex_string).convert(:latex)
    #   rescue
    #     a = nil
    #   end

#   entry = (a.nil? ? nil : a.first)
#   src = (entry.nil? ? Source::Bibtex.new : Source::Bibtex.new_from_bibtex(entry))
#   status = (src.valid? ? "OK" : "FAILED")
#   format.html {render action: 'new'}
#   retval = {status: status, valid: src.valid?, errors: src.errors.messages, source: src}
#   format.json {render json: retval}
#   if((src.valid?)&&(params['create_bibtex']=='true'))
#     src.save!
#   end
  end

  # PATCH/PUT /sources/1
  # PATCH/PUT /sources/1.json
  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to url_for(@source.metamorphosize), notice: 'Source was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.json
  def destroy
    @source.destroy!
    respond_to do |format|
      format.html { redirect_to sources_url }
      format.json { head :no_content }
    end
  end

  def autocomplete
    @sources = Queries::Source::Autocomplete.new(
      params.require(:term),
      autocomplete_params
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

  # GET /sources/batch_load    This is deprecated
  def batch_load
  end

  def preview_bibtex_batch_load
    file = params.require(:file)
    redirect_to batch_load_sources_path, notice: 'No file has been selected.' and return if file.blank?
    file_ok, mimetype = Utilities::Files.recognized_batch_file_type?(file.tempfile)
    if !file_ok
      redirect_to batch_load_sources_path,
        notice: "File '#{file.original_filename}' is of type '#{mimetype}', and not processable as BibTex."
    else
      @sources  = Source.batch_preview(file.tempfile)
      sha256 = Digest::SHA256.file(file.tempfile)
      cookies[:batch_sources_md5] = sha256.hexdigest
      render 'sources/batch_load/bibtex_batch_preview'
    end
  end

  def create_bibtex_batch_load
    file = params.require(:file)
    redirect_to batch_load_sources_path, notice: 'no file has been selected' and return if file.blank?
    sha256 = Digest::SHA256.file(file.tempfile)
    if cookies[:batch_sources_md5] == sha256.hexdigest
      if result_hash = Source.batch_create(file.tempfile)
        # error in results?
        @count         = result_hash[:count]
        @sources       = result_hash[:records]
        flash[:notice] = "Successfully batch created #{@count} sources."
        render 'sources/batch_load/bibtex_batch_create'
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
    send_data Download.generate_csv(Source.all), type: 'text', filename: "sources_#{DateTime.now}.csv"
  end

  private

  def autocomplete_params
    params.permit(:limit_to_project).merge(project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  def set_source
    @source        = Source.find(params[:id])
    @recent_object = @source
  end

  def batch_params
  end

  def source_params
    params['source'][:project_sources_attributes] = [{project_id: sessions_current_project_id.to_s}]
    params.require(:source).permit(
      :serial_id, :address, :annote, :author, :booktitle, :chapter,
      :crossref, :edition, :editor, :howpublished, :institution,
      :journal, :key, :month, :note, :number, :organization, :pages,
      :publisher, :school, :series, :title, :type, :volume, :doi,
      :abstract, :copyright, :language, :stated_year, :verbatim,
      :bibtex_type, :day, :year, :isbn, :issn, :verbatim_contents,
      :verbatim_keywords, :language_id, :translator, :year_suffix, :url, :type,
      roles_attributes:           [
                                    :id,
                                    :_destroy,
                                    :type,
                                    :person_id,
                                    :position,
                                    person_attributes: [
                                                         :last_name, :first_name, :suffix, :prefix
                                                       ]
                                  ],
      project_sources_attributes: [:project_id]
    )
  end
end
