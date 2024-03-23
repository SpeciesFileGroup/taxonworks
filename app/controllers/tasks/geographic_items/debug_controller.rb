class Tasks::GeographicItems::DebugController < ApplicationController
  include TaskControllerConfiguration

  def index
    @geographic_item = GeographicItem.find(params[:geographic_item_id] || params[:id])
  end

end
