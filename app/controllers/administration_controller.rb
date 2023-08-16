#
# This is a top-level class documentation comment for the Administration Controller

class AdministrationController < ApplicationController
  before_action :require_administrator_sign_in

  def index
  end

  def user_activity
  end

  def data_overview
  end

  def data_health
  end

  def data_reindex
  end

  def cached_maps_status
  end

  def data_class_summary
    @klass = params.require(:klass)&.safe_constantize
    @time_span = params.require(:time_span)
    @target = params.require(:target)
    @projects = params[:project_id].blank? ? Project.all : Project.where(id: params[:project_id])
    @start_date = (params[:start_date].presence || 1000.years.ago.to_date)
    @end_date = (params[:end_date].presence || 1.day.from_now.to_date)
  end

end
