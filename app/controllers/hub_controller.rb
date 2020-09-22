class HubController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_links_to_render

  # GET /hub
  def index
    handle_bad_tab_order
    respond_to do |format|
      format.html {}
      format.js {
        render partial: 'navigation_index' # layout: nil
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

  def handle_bad_tab_order
    # This is preventative only, it should never happen in real data, and may only occur when 
    # we reset tab performance.
    if @sessions_current_user.hub_tab_order.empty?
      # TODO: update_column likely
      @sessions_current_user.update_attribute(:hub_tab_order, DEFAULT_HUB_TAB_ORDER)
    end
    true
  end

  def set_links_to_render
    @links_to_render = params[:list]
    @links_to_render ||= @sessions_current_user.hub_tab_order.first
  end

end
