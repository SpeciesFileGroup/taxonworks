class Tasks::Bibliography::VerbatimReferenceController <ApplicationController
  include TaskControllerConfiguration

  # GET build_source_from_crossref_task_path
  def new
  end


  # POST
  def create
    @source = Source.new_from_citation(citation: params[:citation])
    if @source.save 
      flash[:notice] = 'Successfully created a new record, resolved to bibtex format.'
    else
      flash[:notice] = 'There was an error creating the record.'
    end
    render :new
  end

end
