class Tasks::Projects::YearInReviewController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/projects/year_in_review
  def index
    @year = (params[:year] || Time.current.year).to_i
    @available_years = helpers.available_years_for_review(sessions_current_project_id)
    @form_url = year_in_review_task_path
    @data_url = year_in_review_data_path(format: :json)
  end

  # GET /tasks/projects/year_in_review/data.json
  def data
    year = (params[:year] || Time.current.year).to_i
    render json: helpers.year_in_review_data(year, sessions_current_project_id)
  end

end
