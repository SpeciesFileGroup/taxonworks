class SourcesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :require_sign_in 
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  # GET /sources
  # GET /sources.json
  def index
    @recent_objects = Source.created_this_week.order(updated_at: :desc).limit(10)
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
        format.html { redirect_to @source.metamorphosize, notice: 'Source was successfully created.' }
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

    data = @sources.collect do |t|
      {id: t.id,
       label: SourcesHelper.source_tag(t),
       response_values: {
         params[:method] => t.id  
       },
       label_html: SourcesHelper.source_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data 
 
  end

  def batch_preview
    @sources = Source.batch_preview(file: params[:file].tempfile)
  end

  def batch_create
    if @sources = Source.batch_create(params.symbolize_keys.to_h)
      flash[:notice] = "Successfully batch created #{@sources.count} OTUs."
    else
      flash[:notice] = 'Failed to create the sources.'
    end
    redirect_to sources_path
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source
      @source = Source.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_params
      params.require(:source).permit(:serial_id, :address, :annote, :author, :booktitle, :chapter, :crossref, :edition, :editor, :howpublished, :institution, :journal, :key, :month, :note, :number, :organization, :pages, :publisher, :school, :series, :title, :type, :volume, :doi, :abstract, :copyright, :language, :stated_year, :verbatim,  :bibtex_type, :nomenclature_date, :day, :year, :isbn, :issn, :verbatim_contents, :verbatim_keywords, :language_id, :translator, :year_suffix, :url)
    end
end
