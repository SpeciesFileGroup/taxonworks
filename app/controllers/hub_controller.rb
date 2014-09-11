class HubController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_links_to_render

  # GET /hub
  def index

     respond_to do |format|
       format.html {}
       format.js {
         render partial: 'navigation_index' # layout: nil
       }
    end 
  end

  protected

  def set_links_to_render
    @links_to_render = params[:list]
    @links_to_render ||= 'favorite' # TODO: Change to recent 
  end

end
