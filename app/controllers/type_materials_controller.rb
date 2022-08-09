class TypeMaterialsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_type_material, only: [:show, :edit, :update, :destroy]

  # GET /type_materials
  # GET /type_materials.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = TypeMaterial.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @type_materials = TypeMaterial.where(filter_params).with_project_id(sessions_current_project_id)
      }
    end
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
    @type_material.source = Source.new if !@type_material.source
  end

  # POST /type_materials
  # POST /type_materials.json
  def create
    @type_material = TypeMaterial.new(type_material_params)

    respond_to do |format|
      if @type_material.save
        msg = "Type material (#{@type_material.type_type}) " \
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
    @type_materials = TypeMaterial.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def search
    if params[:id].blank?
      redirect_to(type_materials_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.')
    else
      redirect_to type_material_path(params[:id])
    end
  end

  def autocomplete
    @type_materials = Queries::TypeMaterialAutocompleteQuery.new(params[:term], project_id: sessions_current_project_id).all

    data = @type_materials.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.type_material_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html: ApplicationController.helpers.type_material_tag(t)
      }
    end

    render json: data
  end

  # GET /type_materials/download
  def download
    send_data Export::Download.generate_csv(TypeMaterial.where(project_id: sessions_current_project_id)), type: 'text', filename: "type_materials_#{DateTime.now}.csv"
  end

  def type_types
    render json: {
      icn: TypeMaterial::ICN_TYPES.inject({}){|hsh, k| hsh.merge!(k[0] =>  k[1].name)},
      iczn: TypeMaterial::ICZN_TYPES.inject({}){|hsh, k| hsh.merge!(k[0] => k[1].name)}
    }
  end

  private

  def filter_params
    params.permit(:protonym_id, :collection_object_id, :type_type)
  end

  def set_type_material
    @type_material = TypeMaterial.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @type_material
  end

  def type_material_params
    params.require(:type_material).permit(
      :protonym_id, :collection_object_id, :type_type,
      roles_attributes: [:id, :_destroy, :type, :person_id, :position, person_attributes: [:last_name, :first_name, :suffix, :prefix]],
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
      collection_object_attributes: [
        :id, :buffered_collecting_event, :buffered_other_labels, :buffered_determinations,
        :total, :collecting_event_id, :preparation_type_id, :repository_id]
    )
  end
end
