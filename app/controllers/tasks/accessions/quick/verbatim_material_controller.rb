class Tasks::Accessions::Quick::VerbatimMaterialController < ApplicationController
  include TaskControllerConfiguration
  before_filter :set_fixed_variables

  # GET quick_verbatim_material_task
  def new
    @material = Material::QuickVerbatimResponse.new
    @related_routes = UserTasks.related_routes('quick_verbatim_material_task')
    set_variable_variables(@material)
  end

  # POST tasks_accessions_quick_verbatim_material_create_path
  def create
    @material = Material.create_quick_verbatim(params.to_h)

    saved, errors = @material.save

    if saved
      flash[:notice] = 'Added records.'
      @material = @material.duplicate_with_locks
    else
      flash[:notice] =  "Failed to add records #{errors.messages}"
    end

    set_variable_variables(@material)
    render :new
  end

  protected

  def set_fixed_variables
    @repositories = Repository.order(:name).all
    @namespaces = Namespace.order(:name).all
    @biocuration_groups = BiocurationGroup.with_project_id($project_id) 
  end

  def set_variable_variables(material)
    @locks = material.locks_object
    @collection_object = material.collection_object
    @identifier = material.identifier
    @repository = material.repository
    @note = material.note
  end

  def material_params
    # params.require(:identifier) , :locks, :repository, :collection_object, :note, :collection_objects).permit(:note, :collection_object, :identifier, :repository, :locks)
  end

  
end
