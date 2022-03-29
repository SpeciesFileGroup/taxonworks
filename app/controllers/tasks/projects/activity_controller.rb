class Tasks::Projects::ActivityController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project = sessions_current_project
  end

  def type_report
    @klass = params.require(:klass)&.safe_constantize
    @time_span = params.require(:time_span)
    @target = params.require(:target)
    @projects = params[:project_id].blank? ? Project.all : Project.where(id: params[:project_id])
    @users = params[:user_id].blank? ? sessions_current_project.users.order(:name) : User.where(id: params[:user_id]).order(:name)
    @start_date = params[:start_date].blank? ? 1000.year.ago.to_date : params[:start_date]
    @end_date = params[:end_date].blank? ? 1.day.from_now.to_date : params[:end_date]

    @data = @users.map{|p| {
      id: p.id,
      name: p.name,
      data: @klass.where(project_id: sessions_current_project_id, "#{@target}_by_id": p.id)
      .where("#{@klass.table_name}.#{@target}_at BETWEEN ? AND ?", @start_date, @end_date)
      .send("group_by_#{@time_span}", "#{@target}_at".to_sym ).count}}
      .select{|h| !h[:data].empty?}
  end

end
