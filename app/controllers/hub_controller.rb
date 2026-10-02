class HubController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_links_to_render

  # GET /hub
  def index
    handle_bad_tab_order
    respond_to do |format|
      format.html {}
   # TODO not used?!
   #  format.js {
   #    render partial: 'navigation_index' # layout: nil
   #  }
      format.json{
        render json: helpers.hub_json
      }
    end 
  end

  def tasks
    @tasks = UserTasks.hub_tasks(params[:category])
  end

  def order_tabs
    handle_bad_tab_order
  end

  def update_tab_order
    # TODO: update_column likely 
    @sessions_current_user.update_attribute(:hub_tab_order, params[:order])
    head :ok
  end

  protected

  # Appends default tabs missing from the user's order, e.g. an empty order
  # after a reset, or tabs added since the order was saved.
  def handle_bad_tab_order
    missing = DEFAULT_HUB_TAB_ORDER - @sessions_current_user.hub_tab_order
    if missing.any?
      # TODO: update_column likely
      @sessions_current_user.update_attribute(
        :hub_tab_order, @sessions_current_user.hub_tab_order + missing
      )
    end
    true
  end

  def set_links_to_render
    @links_to_render = params[:list]
    @links_to_render ||= @sessions_current_user.hub_tab_order.first
  end

end
