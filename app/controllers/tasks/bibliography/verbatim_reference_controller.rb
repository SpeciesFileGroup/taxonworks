class Tasks::Bibliography::VerbatimReferenceController <ApplicationController
  include TaskControllerConfiguration

  # GET build_source_from_crossref_task_path
  def new
  end


  # POST
  def create
    @source = Source.new_from_citation(citation: params[:citation])
    if @source.save
      flash[:notice] = "A #{@source.class} record was created."
      if params[:create_roles]
        if @source.create_related_people_and_roles 
          flash[:notice] = "Successfully created from resolution to bibtex, also created #{@source.roles.count} people as authors/editors."
        else
          flash[:notice] = 'Successfully created from resolution to bibtex, associated People records were not created.'
        end
      end
    else
      flash[:notice] = 'There was an error creating the record.'
    end
    render :new
  end

end
