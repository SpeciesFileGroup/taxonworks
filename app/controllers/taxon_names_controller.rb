class TaxonNamesController < ApplicationController
  include DataControllerConfiguration

  before_action :set_taxon_name, only: [:show, :edit, :update, :destroy]

  # GET /taxon_names
  # GET /taxon_names.json
  def index
    @taxon_names    = TaxonName.all
    @recent_objects = TaxonName.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    # todo: temporary, to at least show something
    @recent_objects = TaxonName.with_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  # GET /taxon_names/1
  # GET /taxon_names/1.json
  def show
  end

  # GET /taxon_names/new
  def new
    @taxon_name = Protonym.new
  end

  # GET /taxon_names/1/edit
  def edit
  end

  # POST /taxon_names
  # POST /taxon_names.json
  def create
    @taxon_name = TaxonName.new(taxon_name_params)

    respond_to do |format|
      if @taxon_name.save
        format.html { redirect_to @taxon_name.becomes(TaxonName), notice: 'Taxon name was successfully created.' }
        format.json { render action: 'show', status: :created, location: @taxon_name }
      else
        format.html { render action: 'new' }
        format.json { render json: @taxon_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_names/1
  # PATCH/PUT /taxon_names/1.json
  def update
    respond_to do |format|
      if @taxon_name.update(taxon_name_params)
        format.html { redirect_to @taxon_name.becomes(TaxonName), notice: 'Taxon name was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @taxon_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_names/1
  # DELETE /taxon_names/1.json
  def destroy
    @taxon_name.destroy
    respond_to do |format|
      format.html { redirect_to taxon_names_url }
      format.json { head :no_content }
    end
  end

  def search
    if params[:taxon_name] && params[:taxon_name][:id]
      redirect_to taxon_name_path(params[:taxon_name][:id])
    else
      redirect_to taxon_names_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  def autocomplete
    @taxon_names = TaxonName.where('name LIKE ?', "#{params[:term]}%") # find_for_auto_complete(conditions, table_name)

    data = @taxon_names.collect do |t|
      {id:              t.id,
       label:           TaxonNamesHelper.taxon_name_tag(t),
       response_values: {
         # 'taxon_name[id]' => t.id, <- pretty sure this will bork things.
         params[:method] => t.id
       },
       label_html:      TaxonNamesHelper.taxon_name_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  def list
    @taxon_names = TaxonName.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_taxon_name
    @taxon_name = TaxonName.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def taxon_name_params
    params.require(:taxon_name).permit(:name, :parent_id, :cached_author_year, :source_id, :year_of_publication, :verbatim_author, :rank_class, :type,)
  end

end
