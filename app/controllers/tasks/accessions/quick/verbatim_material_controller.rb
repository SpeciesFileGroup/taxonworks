class Tasks::Accessions::Quick::VerbatimMaterialController < ApplicationController
  include TaskControllerConfiguration
  before_action :set_fixed_variables, :get_recent

  # GET quick_verbatim_material_task
  def new
    @material = Material::QuickVerbatimResponse.new(material_params)
    @related_routes = UserTasks.related_routes('quick_verbatim_material_task')
    set_variable_variables(@material)
  end

  # POST tasks_accessions_quick_verbatim_material_create_path
  def create
    @material = Material.create_quick_verbatim(material_params)

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

  def get_recent
    @recent = CollectionObject.created_last(5).where(created_by_id: sessions_current_user_id, project_id: sessions_current_project_id)
  end



  def set_fixed_variables
    @repositories       = Repository.order(:name).all
    @namespaces         = Namespace.order(:name).all
    @biocuration_groups = BiocurationGroup.with_project_id($project_id)
  end

  def set_variable_variables(material)
    @locks = material.locks

    @collection_object = material.collection_object
    @identifier = material.identifier
    @namespace = material.namespace
    @repository = material.repository
    @note = material.note
  end

  def material_params
    # params.permit(:collection_object, :identifier, :repository, :locks, :note, :collection_objects, :commit).to_unsafe_h
    #TODO this is a security problem needing resolution @mjy
    params.to_unsafe_h
  end


end
