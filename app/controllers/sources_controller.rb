class SourcesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :require_sign_in
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  # GET /sources
  # GET /sources.json
  def index
    @recent_objects = Source.created_this_week.order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  def list
    @sources = Source.order(:id).page(params[:page])
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
  def create
    @source = Source.new(source_params)

    respond_to do |format|
      if @source.save
        case @source.class.to_s
          when 'Source::Bibtex'
            format.html { redirect_to @source.metamorphosize, notice: "Source by '#{@source.author}' was successfully created." }
          when 'Source::Verbatim'
            format.html { redirect_to @source.metamorphosize, notice: "Source '#{@source.cached}' was successfully created." }
          else # type human
            format.html { redirect_to @source.metamorphosize, notice: "Source '#{@source.cached_author_string}' was successfully created." }
        end

        format.json { render action: 'show', status: :created, location: @source }
      else
        format.html { render action: 'new' }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sources/1
  # PATCH/PUT /sources/1.json
  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to @source.metamorphosize, notice: 'Source was successfully updated.' }
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
    @source.destroy
    respond_to do |format|
      format.html { redirect_to sources_url }
      format.json { head :no_content }
    end
  end

  def autocomplete
    @sources = Source.find_for_autocomplete(params)
    data     = @sources.collect do |t|
      {id:              t.id,
       label:           SourcesHelper.source_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      SourcesHelper.source_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end
    render :json => data
  end

  def search
    if params[:id].blank?
      redirect_to sources_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to source_path(params[:id])
    end
  end

  def batch_load
  end

  def preview_bibtex_batch_load 
    @sources  = Source.batch_preview(file: params[:file].tempfile)
    sha256 = Digest::SHA256.file(params[:file].tempfile)
    cookies[:batch_sources_md5] = sha256.hexdigest
    render 'sources/batch_load/batch_preview'
  end

  def create_bibtex_batch_load
    sha256 = Digest::SHA256.file(params[:file].tempfile)
    if cookies[:batch_sources_md5] == sha256.hexdigest
      if @sources = Source.batch_create(params.symbolize_keys.to_h)
        flash[:notice] = "Successfully batch created #{@sources.count} sources."
      else
        flash[:notice] = 'Failed to create the sources.'
      end
    else
      flash[:notice] = 'Batch upload must be previewed before it can be created.'
    end
    redirect_to sources_path
  end

  # GET /sources/download
  def download
    send_data Source.generate_download( Source.all ), type: 'text', filename: "sources_#{DateTime.now.to_s}.csv"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_source
    @source = Source.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def source_params
    params.require(:source).permit(:serial_id, :address, :annote, :author, :booktitle, :chapter, :crossref, :edition, :editor, :howpublished, :institution, :journal, :key, :month, :note, :number, :organization, :pages, :publisher, :school, :series, :title, :type, :volume, :doi, :abstract, :copyright, :language, :stated_year, :verbatim, :bibtex_type, :day, :year, :isbn, :issn, :verbatim_contents, :verbatim_keywords, :language_id, :translator, :year_suffix, :url, :type)
  end
end
