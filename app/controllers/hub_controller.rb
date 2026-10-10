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
    @sessions_current_user.update_column(:hub_tab_order, params[:order])
    head :ok
  end

  protected

  # Appends default tabs missing from the user's order, e.g. an empty order
  # after a reset, or tabs added since the order was saved. If favorite was
  # last (as in the default order) it stays last, so users who never
  # reordered end up with the current default order.
  def handle_bad_tab_order
    order = @sessions_current_user.hub_tab_order
    missing = DEFAULT_HUB_TAB_ORDER - order
    if missing.any?
      new_order =
        if order.last == 'favorite'
          order[0..-2] + missing + ['favorite']
        else
          order + missing
        end
      @sessions_current_user.update_column(:hub_tab_order, new_order)
    end
    true
  end

  def set_links_to_render
    @links_to_render = params[:list]
    @links_to_render ||= @sessions_current_user.hub_tab_order.first
  end

end
