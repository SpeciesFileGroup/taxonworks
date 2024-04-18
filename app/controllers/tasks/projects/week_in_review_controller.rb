class Tasks::Projects::WeekInReviewController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @weeks_ago = (params[:weeks_ago] || 1).to_i
  end

  def data
    @weeks_ago = params[:weeks_ago].to_i || 1
    render json: helpers.week_in_review(@weeks_ago)
  end

end
