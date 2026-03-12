class Tasks::Administrator::YearInReviewController < ApplicationController
  include SuperuserControllerConfiguration

  # GET /tasks/administrator/year_in_review
  def index
    @year = (params[:year] || Time.current.year).to_i
    @available_years = helpers.available_years_for_review(nil)
    @form_url = administrator_year_in_review_task_path
    @data_url = administrator_year_in_review_data_path(format: :json)
    render 'tasks/projects/year_in_review/index'
  end

  # GET /tasks/administrator/year_in_review/data.json
  def data
    year = (params[:year] || Time.current.year).to_i
    render json: helpers.year_in_review_data(year, nil)
  end

end
