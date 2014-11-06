class Tasks::Bibliography::VerbatimReferenceController <ApplicationController
  include TaskControllerConfiguration

  # GET build_source_from_crossref_task_path
  def new
  end


  # POST
  def create
    @p = params[:citation]

    #c = Ref2bibtex.get(@p)
    #source = Source.new(c)
    source = Source.new_from_citation(citation: @p)

    if source
      @b =   source.class
    else
      @b =   'The reference could not be resolved'
    end

    render :new
  end

end
