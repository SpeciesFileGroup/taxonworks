class CompositionsController < ApplicationController
  include RenderControllerConfiguration

  before_action :set_composition, only: [:show, :edit, :update, :destroy]
  after_action -> { set_pagination_headers(:compositions) }, only: [:index], if: :json_request?

  # GET /compositions
  # GET /compositions.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Composition.visible_to_project(sessions_current_project_id)
          .order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @compositions = visible_compositions
          .order(:type, :name)
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /compositions/1
  # GET /compositions/1.json
  def show
  end

  # GET /compositions/new
  def new
    @composition = Composition.new
  end

  # GET /compositions/1/edit
  def edit
  end

  def list
    @compositions = Composition.visible_to_project(sessions_current_project_id)
      .order(:id)
      .page(params[:page])
  end

  # POST /compositions
  # POST /compositions.json
  def create
    @composition = Composition.new(composition_params.merge(type: params.dig(:composition, :type)))

    respond_to do |format|
      if @composition.save
        format.html { redirect_to url_for(@composition.metamorphosize), notice: 'Composition was successfully created.' }
        format.json { render :show, status: :created, location: @composition.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @composition.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /compositions/1
  # PATCH/PUT /compositions/1.json
  def update
    respond_to do |format|
      if @composition.update(composition_params)
        @composition = @composition.metamorphosize
        format.html { redirect_to url_for(@composition), notice: 'Composition was successfully updated.' }
        format.json { render :show, status: :ok, location: @composition }
      else
        format.html { render :edit }
        format.json { render json: @composition.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /compositions/1
  # DELETE /compositions/1.json
  def destroy
    @composition.destroy
    respond_to do |format|
      if @composition.destroyed?
        format.html { redirect_to compositions_url, notice: 'Composition was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @composition, notice: 'Composition was not destroyed, ' + @composition.errors.full_messages.join('; ') }
        format.json { render json: @composition.errors, status: :unprocessable_content }
      end
    end
  end

  def search
    if params[:id].blank?
      redirect_to compositions_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to composition_path(params[:id])
    end
  end

  def autocomplete
    # TODO: expand, move to queries..autocomplete
    @compositions = visible_compositions
      .where('name ILIKE ?', "%#{params.require(:term)}%")
      .order(:type, :name)
      .limit(20)
  end

  private

  # @return [Scope]
  #   Compositions visible to the project, optionally only those of
  #   params[:type] (e.g. Layout), including its subclasses. An unknown
  #   type matches nothing.
  def visible_compositions
    klass = Composition
    if params[:type].present?
      klass = params[:type].safe_constantize
      return Composition.none if !(klass.is_a?(Class) && klass <= Composition)
    end
    klass.visible_to_project(sessions_current_project_id)
  end

  def set_composition
    @composition = Composition.visible_to_project(sessions_current_project_id).find(params[:id])
    @recent_object = @composition
  end

  # type is set only on create
  def composition_params
    params.require(:composition).permit(:name, :description, :is_community)
  end
end
