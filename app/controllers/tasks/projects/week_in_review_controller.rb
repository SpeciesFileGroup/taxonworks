class Tasks::Projects::WeekInReviewController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @weeks_ago = params[:weeks_ago].to_i || 1
  end

end
