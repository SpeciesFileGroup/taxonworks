class Tasks::Bibliography::VerbatimReferenceController < ApplicationController
  include TaskControllerConfiguration

  # GET build_source_from_crossref_task_path
  def new
  end

  def preview
    if citation_param.blank?
      flash[:notice] = 'Provide a citation.'
      render :new and return
    else
      @source = TaxonWorks::Vendor::Serrano.new_from_citation(citation: citation_param)
    end
  end

  def create_verbatim
    @source = Source.new(source_params)
    if @source.save
      flash[:notice] = 'Created source as verbatim.'
      redirect_to url_for(@source.metamorphosize)
    else
      flash[:notice] = "Failed to create verbatim source. #{@source.errors.full_messages}."
      render :new
    end
  end

  def create_bibtex
    @source = TaxonWorks::Vendor::Serrano.new_from_citation(citation: params[:in_cite])
    @source.project_sources_attributes = [{project_id: sessions_current_project_id}]

    if @source.save
      flash[:notice] = 'Created BibTeX record.'
      if params[:create_roles]
        if @source.create_related_people_and_roles
          flash[:notice] << "Successfully created added #{@source.roles.count} people as authors/editors."
        else
          flash[:notice] << 'Associated People records were not created.'
        end
      end
      redirect_to url_for(@source.metamorphosize)
    else
      flash[:notice] = "An error occurred while creating the source record. #{@source.errors.messages}"
      redirect_to new_verbatim_reference_task_path(request.parameters)
    end
  end

  protected

  def citation_param
    begin
      params.require(:citation)
    rescue ActionController::ParameterMissing
      nil
    end
  end

  def source_params
    params['source'][:project_sources_attributes] = [{project_id: sessions_current_project_id.to_s}]

    params.require(:source).permit(
      :verbatim,
      :type,
      project_sources_attributes: [:project_id]
    )
  end

end
