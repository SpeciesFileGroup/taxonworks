class Tasks::Accessions::Quick::VerbatimMaterialController < ApplicationController
  include TaskControllerConfiguration

  # GET quick_verbatim_material_task
  def new
    @repositories = Repository.order(:name).all
    @namespaces = Namespace.order(:name).all

    @biocuration_groups = BiocurationGroup.with_project_id($project_id) 
  end

  # POST tasks_accessions_quick_verbatim_material_create_path
  def create
    @material = Material.create_quick_verbatim(params)
    saved, errors = @material.save
    flash[:notice] = ( saved  ? 'Added records' : "Failed to add records #{errors.messages}" )
    redirect_to quick_verbatim_material_task_path
  end

end
