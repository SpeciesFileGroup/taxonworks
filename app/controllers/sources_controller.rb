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
  def create
    @source = Source.new(source_params)

    respond_to do |format|
      if @source.save
        case @source.type
          when 'Source::Bibtex'
            format.html { redirect_to @source.metamorphosize, notice: "Source by '#{@source.author}' was successfully created." }
          when 'Source::Verbatim'
            format.html { redirect_to @source.metamorphosize, notice: "Source '#{@source.cached}' was successfully created." }
          else # type human
            format.html { redirect_to @source.metamorphosize, notice: "Source '#{@source.cached_author_string}' was successfully created." }
        end

        format.json { render action: 'show', status: :created, location: @source }
      else
        if @source.type == 'Source::Bibtex' && source_params['roles_attributes'].try(:count).to_i > 0
          # has an author or editor so force create...
          if @source.errors.get(:base).include?('Missing core data. A TaxonWorks source must have one of the following: author, editor, booktitle, title, url, journal, year, or stated year')
            @source.title = 'forced'
            if @source.save
              @source.title = ''
              @source.save #TODO may need to add a test to confirm it saves the second time.
              format.html { redirect_to @source.metamorphosize, notice: "Source by '#{@source.author}' was successfully created." }
            else
              format.html { render action: 'new' }
              format.json { render json: @source.errors, status: :unprocessable_entity }
            end
          end
        else
          format.html { render action: 'new' }
          format.json { render json: @source.errors, status: :unprocessable_entity }
        end
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
       label:           ApplicationController.helpers.source_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      ApplicationController.helpers.source_tag(t)
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

  # GET /sources/batch_load    This is deprecated
  def batch_load
  end

  def preview_bibtex_batch_load
    file = params[:file]
    if file.blank?
      redirect_to batch_load_sources_path, notice: 'No file has been selected.'
    else
      begin # file type testing: Permit UTF-8, ASCII
        failed   = false
        mimetype = `file -b "#{file.tempfile.path}"`.gsub(/\n/, '')
        case mimetype
          when /utf-8/i, /ascii/i
            failed = false # redundant, but good for debugging
          else
            failed = true
        end
        if failed
          redirect_to batch_load_sources_path, notice: "File '#{file.original_filename}' is of type '#{mimetype}', and not processable as BibTex."
        else
          @sources                    = Source.batch_preview(file: file.tempfile)
          sha256                      = Digest::SHA256.file(file.tempfile)
          cookies[:batch_sources_md5] = sha256.hexdigest
          render 'sources/batch_load/bibtex_batch_preview'
        end
      end
    end
  end

  def create_bibtex_batch_load
    if params[:file].nil?
      redirect_to batch_load_sources_path, notice: 'no file has been selected'
    else
      sha256 = Digest::SHA256.file(params[:file].tempfile)
      if cookies[:batch_sources_md5] == sha256.hexdigest
        if result_hash = Source.batch_create(params.symbolize_keys.to_h)
          @count         = result_hash[:count]
          @sources       = result_hash[:records]
          flash[:notice] = "Successfully batch created #{@count} sources."
          render 'sources/batch_load/bibtex_batch_create' # and return
        else
          flash[:notice] = 'Failed to create the sources.'
          redirect_to batch_load_sources_path
        end
      else
        flash[:notice] = 'Batch upload must be previewed before it can be created.'
        redirect_to batch_load_sources_path
      end
#      redirect_to sources_path
    end
  end

  # GET /sources/download
  def download
    send_data Source.generate_download(Source.all), type: 'text', filename: "sources_#{DateTime.now.to_s}.csv"
  end

  private

  def set_source
    @source        = Source.find(params[:id])
    @recent_object = @source
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
      roles_attributes:           [:id, :_destroy, :type, :person_id, :position, person_attributes: [:last_name, :first_name, :suffix, :prefix]],
      project_sources_attributes: [:project_id]
    )
  end
end
