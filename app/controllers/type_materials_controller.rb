class TypeMaterialsController < ApplicationController
  before_action :set_type_material, only: [:show, :edit, :update, :destroy]

  # GET /type_materials
  # GET /type_materials.json
  def index
    @type_materials = TypeMaterial.all
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
        format.html { redirect_to @type_material, notice: 'Type material was successfully created.' }
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
