class TaxonNamesController < ApplicationController
  include DataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_taxon_name, only: [:show, :edit, :update, :destroy]

  # GET /taxon_names
  # GET /taxon_names.json
  def index
    @taxon_names = TaxonName.limit(100)
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

  def auto_complete_for_taxon_names
  #  table_name = "tn"  # alias for the TaxonName joins needed
  #  value = params[:term]
  #  if params[:use_proj] == 'false'
  #    proj_sql = ""
  #  else
  #    proj_sql = "AND (" + @proj.sql_for_taxon_names(table_name) + ")" 
  #  end
     
  #  # possible conditions are [all, genus, species, family]
  #  if params[:name_group] == 'all'
  #    conditions = ["(#{table_name}.name LIKE ? or #{table_name}.id = ? or #{table_name}.author LIKE ? or #{table_name}.year = ?) #{proj_sql}", "#{value.downcase}%", "#{value.downcase}%", "#{value}%", "#{value.downcase}" ]
  #  else
  #    conditions = ["(#{table_name}.name LIKE ?  or #{table_name}.author LIKE ? or #{table_name}.year = ?) AND #{table_name}.iczn_group = ? #{proj_sql}", "#{value.downcase}%",  "#{value.downcase}%", "#{value.downcase}", params[:name_group]]
  #  end

    @taxon_names = TaxonName.where('name LIKE ?', "#{params[:term]}%") # find_for_auto_complete(conditions, table_name)

    data = @taxon_names.collect do |t|
      {id: t.id,
       label: TaxonNamesHelper.display_taxon_name(t), # .display_name(:type => :selected),
       response_values: {
         # 'taxon_name[id]' => t.id, <- pretty sure this will bork things.
         params[:method] => t.id  
       },
       label_html: TaxonNamesHelper.display_taxon_name(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data 
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_taxon_name
    @taxon_name = TaxonName.find(params[:id])
  end





  # Never trust parameters from the scary internet, only allow the white list through.
  def taxon_name_params
    params.require(:taxon_name).permit(:name, :parent_id, :cached_name, :cached_author_year, :cached_higher_classification, :lft, :rgt, :source_id, :year_of_publication, :verbatim_author, :rank_class, :type, :created_by_id, :updated_by_id, :project_id, :cached_original_combination, :cached_secondary_homonym, :cached_primary_homonym, :cached_secondary_homonym_alt, :cached_primary_homonym_alt)
  end

end
