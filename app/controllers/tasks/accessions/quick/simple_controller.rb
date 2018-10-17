class Tasks::Accessions::Quick::SimpleController < ApplicationController
  include TaskControllerConfiguration

  before_action :build_locks, :get_recent, only: [:new, :create]

  # POST /tasks/accessions/simple/new.html
  def new
    @specimen = stub(defaults: locked_params(locks: @locks))
  end

  # POST /tasks/accessions/simple/create.json
  # POST /tasks/accessions/simple/create.html
  def create
    @specimen = Specimen.new(specimen_params)
    if @specimen.save
      flash[:notice] = 'Specimen was successfully created.'
      @locked_params = locked_params(locks: @locks)
      respond_to do |format|
        format.html {
          @specimen = stub(defaults: @locked_params)
          render :new
        }
        format.json { render json: @locked_params }
      end
    else
      flash[:notice] = "Specimen was NOT created. #{@specimen.errors.full_messages}"
      render :new
    end
  end

  def collecting_events
    @collecting_events = CollectingEvent.where(project_id: sessions_current_project_id).where('verbatim_locality ILIKE ?', "%#{params[:term]}%").limit(10)
  end

  protected

  def build_locks
    @locks = Forms::FieldLocks.new(lock_params || {})
  end

  def get_recent
    @recent = CollectionObject.created_last(5).where(created_by_id: sessions_current_user_id, project_id: sessions_current_project_id)
  end

  # TODO: move this to model!
  def stub(defaults: {})
    s = Specimen.new(collecting_event_id: defaults[:collecting_event_id] )
    s.preparation_type_id = defaults[:preparation_type_id]

    s.identifiers << Identifier::Local::CatalogNumber.new(
                                                          namespace_id: defaults[:namespace_id],
                                                          identifier: next_identifier
                                                         )

    s.taxon_determinations.build(otu_id: defaults[:otu_id])
    s.collecting_event = CollectingEvent.new if s.collecting_event_id.blank?
    s.depictions << Depiction.new
    s
  end

  def next_identifier
    return nil if !@locks.locked?('identifier', 'increment')
    Utilities::Strings.increment_contained_integer(identifier_param)
  end

  def locked_params(locks: nil)
    {
      collecting_event_id: locks.resolve(:collecting_event, :collecting_event_id, collecting_event_id_param),
      namespace_id: locks.resolve(:identifier, :namespace_id, namespace_id_param ),
      otu_id: locks.resolve(:taxon_determination, :otu_id, otu_id_param),
      preparation_type_id: locks.resolve(:specimen, :preparation_type_id, preparation_type_id_param)
    }
  end

  def specimen_params
    params.require(:specimen).permit(
      # :collecting_event_id,
      :preparation_type_id,
      identifiers_attributes:          [:id, :namespace_id, :identifier, :type, :_destroy],
      tags_attributes:                 [:id, :keyword_id, :_destroy],
      taxon_determinations_attributes: [:id, :otu_id, :_destroy,
                                        otu_attributes: [:id, :_destroy, :name, :taxon_name_id]],
      notes_attributes:                [:id, :text, :_destroy],
      depictions_attributes:           [:_destroy, :image_id, image_attributes: [:id, :image_file]],
      image_array:                     [ recursive_images_params ],
    ).merge(collecting_event_params)
  end

  # https://github.com/rails/rails/issues/9454
  def recursive_images_params
    return [] if params[:specimen].try(:[], :image_array).blank?
    keys = []
    params.require(:specimen).permit(image_array: {})[:image_array].each do |key, value|
      if Utilities::Strings.is_i?(key) && value.is_a?(ActionDispatch::Http::UploadedFile)
        keys.push key
      end
    end
    keys
  end

  # @return [Id, nil]
  def preparation_type_id_param
    begin
      params.require(:specimen).require(:preparation_type_id)

    rescue ActionController::ParameterMissing
      @specimen.preparation_type_id if @specimen
    end
  end

  # @return [Hash]
  def collecting_event_params
    begin
      id = params[:specimen].require(:collecting_event_id)
      {collecting_event_id: id}
    rescue ActionController::ParameterMissing
      params.require(:specimen).permit(collecting_event_attributes: [:id, :_destroy, :verbatim_locality, :verbatim_label, :geographic_area_id]).reject{|k,v| v.blank?}
    end
  end

  def lock_params
    params.permit(locks: {specimen: [:preparation_type_id], identifier: [:namespace_id, :increment], taxon_determination: [:otu_id], collecting_event: [:collecting_event_id] })[:locks]
  end

  def namespace_id_param
    params[:specimen].try(:[], :identifiers_attributes).try(:[], '0').try(:[], :namespace_id)
  end

  def identifier_param
    params[:specimen].try(:[], :identifiers_attributes).try(:[], '0').try(:[], :identifier)
  end

  #
  # Both otu and collecting event can be found or created from scratch, we
  # must therefor look in two different places.
  #

  # @return [Id, nil]
  def otu_id_param
    id = params[:specimen].try(:[], :taxon_determinations_attributes).try(:[], '0').try(:[], 'otu_id')
    if id.blank?
      @specimen.try(:taxon_determinations).try(:first).try(:otu_id)
    else
      id
    end
  end

  def collecting_event_id_param
    id = params[:specimen].try(:collecting_event_id)
    if id.blank?
      @specimen.collecting_event_id if @specimen
    else
      id
    end
  end


end
