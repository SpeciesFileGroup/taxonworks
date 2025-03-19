class MetadataController < ApplicationController
  before_action :require_sign_in_and_project_selection

  after_action -> {set_object_navigation_headers(:object)}, only: [:object_navigation], if: :json_request?

  def index
    @klass = params[:klass]
    render '/shared/data/metadata/index'
  end

  # :klass is a base class name, like "Otu"
  def object_radial
    get_klass
    @data = OBJECT_RADIALS[@klass]
    render '/workbench/navigation/object_radial'
  end

  def object_navigation
    @object = GlobalID::Locator.locate(params.require(:global_id))
    render json: {status: 200}
  end

  def class_navigation
    k = params.require(:klass)
    render json: helpers.class_navigation_json(k)
  end

  def related_summary
    @klass = params.require(:klass).safe_constantize
    render json: @klass.related_summary(params.require(:id))
  end

  # /metadata/annotators.json
  def annotators
    render json: helpers.klass_annotations
  end

  # !! DO NOT EXPOSE TO API !! until santize tested
  def vocabulary

    p = params.permit(:model, :attribute, :begins_with, :limit, :contains, :min, :max).merge(project_id: sessions_current_project_id).to_h.symbolize_keys
    if @words = Vocabulary.words(**p)
      render json: @words, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def data_models
    render json: DATA_MODELS.keys.sort
  end

  # GET /metadata/attributes?model=CollectingEvent&mode=editable
  def attributes
    render json: Vocabulary.attributes(
      Vocabulary.get_model(
        params.require(:model)
      ),
      mode: params[:mode]
    )
  end

  protected

  def get_klass
    render json: {status: 400} if (params[:type] && params[:global_id]) || (params[:type].blank? && params[:global_id].blank?)

    if params[:type]
      @klass = params[:type]
      @object = nil
    else
      @object = GlobalID::Locator.locate(params.require(:global_id))
      @klass = OBJECT_RADIALS[@object.class.name] ? @object.class.name : @object.class.base_class.name
    end
  end

end
