class ContainerItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_container_item, only: [:update, :destroy, :show]

  # GET /container_items
  # GET /container_items.json
  def index
    @recent_objects = ContainerItem.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /container_items/1
  # GET /container_items/1.json
  def show
  end

  def list
    @container_items = ContainerItem.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  # POST /container_items
  # POST /container_items.json
  def create
    @container_item = ContainerItem.new(container_item_params)
    respond_to do |format|
      if @container_item.save
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container item was successfully created.')}
        format.json { render json: @container_item, status: :created, location: @container_item }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container item was NOT successfully created.')}
        format.json { render json: @container_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /container_items/1
  # PATCH/PUT /container_items/1.json
  def update
    respond_to do |format|
      if @container_item.update(container_item_params)
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container item was successfully created.')}
        format.json { render json: @container_item, status: :ok, location: @container_item }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Container item was NOT successfully updated.')}
        format.json { render json: @container_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /container_items/1
  # DELETE /container_items/1.json
  def destroy
    @container_item.destroy
    respond_to do |format|
      format.html { destroy_redirect @container_item, notice: 'Container item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to container_items_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to container_item_path(params[:id])
    end
  end

  def autocomplete
    Queries::ContainerItemAutocompleteQuery.new(
      params.merge(project_id: sessions_current_project_id)
    ).all.where(project_id: params[:project_id]).includes(:taxon_name)
    
    data = @container_items.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.container_item_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.container_item_autocomplete_selected_tag(t)
      }
    end

    render json: data
  end

  private
    def set_container_item
      @container_item = ContainerItem.with_project_id(sessions_current_project_id).find(params[:id])
    end

    def container_item_params
      params.require(:container_item).permit(
        :global_entity,
        :contained_object_id,
        :contained_object_type,
        :container_id,
        :position,
        :parent_id, 
        :disposition)
    end
end
