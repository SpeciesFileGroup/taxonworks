class TypeMaterialsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_type_material, only: [:show, :edit, :update, :destroy]

  # GET /type_materials
  # GET /type_materials.json
  def index
    @recent_objects = TypeMaterial.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  # GET /type_materials/1
  # GET /type_materials/1.json
  def show
  end

  # GET /type_materials/new
  def new
    @type_material = TypeMaterial.new
  end

  # GET /type_materials/1/edit
  def edit
  end

  # POST /type_materials
  # POST /type_materials.json
  def create
    @type_material = TypeMaterial.new(type_material_params)

    respond_to do |format|
      if @type_material.save
        msg =     "Type material (#{@type_material.type_type}) " +
                  "for #{@type_material.protonym.cached} was successfully created."
        format.html { redirect_to @type_material,
                                  notice: msg }
        format.json { render :show, status: :created, location: @type_material }
      else
        format.html { render :new }
        format.json { render json: @type_material.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /type_materials/1
  # PATCH/PUT /type_materials/1.json
  def update
    respond_to do |format|
      if @type_material.update(type_material_params)
        format.html { redirect_to @type_material, notice: 'Type material was successfully updated.' }
        format.json { render :show, status: :ok, location: @type_material }
      else
        format.html { render :edit }
        format.json { render json: @type_material.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /type_materials/1
  # DELETE /type_materials/1.json
  def destroy
    @type_material.destroy
    respond_to do |format|
      format.html { redirect_to type_materials_url, notice: 'Type material was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @type_materials = TypeMaterial.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def autocomplete
    @type_materials = TypeMaterial.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)) # in model

    data = @type_materials.collect do |t|
      {id:              t.id,
       label:           TypeMaterialsHelper.type_material_tag(t), # in helper
       response_values: {
           params[:method] => t.id
       },
       label_html:      TypeMaterialsHelper.type_material_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  # GET /type_materials/download
  def download
    send_data TypeMaterial.generate_download( TypeMaterial.where(project_id: $project_id) ), type: 'text', filename: "controlled_vocabulary_terms_#{DateTime.now.to_s}.csv"
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_type_material
      @type_material = TypeMaterial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def type_material_params
      params.require(:type_material).permit(:protonym_id, :biological_object_id, :type_type, :source_id, :created_by_id, :updated_by_id, :project_id)
    end
end
