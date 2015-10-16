class Tasks::Bibliography::VerbatimReferenceController <ApplicationController
  include TaskControllerConfiguration

  # GET build_source_from_crossref_task_path
  def new
  end


  # POST
  # gets the citation from user and passes it to preview
  def create
    @source = Source.new_from_citation(citation: params[:citation])
    render 'tasks/bibliography/verbatim_reference/preview',
           locals: {citation: params[:citation],
                    source:   @source}
    @source.delete # done with this object
  end

  # lets the user select which type of source to create (and if BibTeX to create people or serials as well)
  def preview
    # Matt said to model this task along the lines of the bulk import with a preview & a create.

    # There is a slight possibility that the resolver will return a different object or changed object
    # the second time the source is sent to the resolver.

    # on success go to edit source ==>  edit_source_path(@source)
    # on fail flash[:notice]; render :new
    continue = true
    if params[:commit] == 'Create verbatim source'
      @source = Source::Verbatim.create(:verbatim => params[:in_cite])
    else # params[:commit] == 'Create BibTeX source'
      @source = Source.new_from_citation(citation: params[:in_cite])
      if @source.class == Source::Verbatim
         continue = false
      end
    end

    if continue && @source.save
      flash[:notice] = "This #{@source.class} record was created."
      if params[:create_roles]
        if @source.create_related_people_and_roles
          flash[:notice] = "Successfully created Bibtex Source, and #{@source.roles.count} people as authors/editors."
        else
          flash[:notice] = 'Successfully created Bibtex Source, associated People records were not created.'
        end
      end
      redirect_to edit_source_path(@source)
    else
      if continue          # save must have failed
        flash[:notice] = "An error occurred while creating the source record. #{@source.errors.messages}"
      else # continue == false so was unable to create the bibtex record
        flash[:notice] = 'BibTeX source was NOT created. The provided citation no longer resolves.'
      end
       redirect_to new_verbatim_reference_task_path(request.parameters)
    end
  end
end
