class Tasks::Projects::ActivityController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project = sessions_current_project
  end

  def type_report
    @klass = params.require(:klass)&.safe_constantize
    @time_span = params.require(:time_span)
    @target = params.require(:target)
    # @projects = params[:project_id].blank? ? Project.all : Project.where(id: params[:project_id])
    @users = params[:user_id].blank? ? sessions_current_project.users.order(:name) : User.where(id: params[:user_id]).order(:name)
    @start_date = params[:start_date].blank? ? 1000.year.ago.to_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? 1.day.from_now.to_date : params[:end_date].to_date

    @data = []

    @users.each do |u|
      d = {
        id: u.id,
        name: u.name
      }

      data = @klass.where("#{@target}_by_id": u.id).where("#{@klass.table_name}.#{@target}_at BETWEEN ? AND ?", @start_date, @end_date)

      if !@klass.is_community?
        data = data.where(project_id: sessions_current_project_id)
      end

      d[:data] = data.send("group_by_#{@time_span}", "#{@target}_at".to_sym ).count
      @data.push d
    end

    @data = @data.select{|h| !h[:data].empty?}

    # This is a kludge to force the x axis labels
    # to be ordered in the graphs that use them.  We
    # ensure that the first record plotted 1) has all
    # labels, and 2) has them sorted in order.
    #
    data_labels = @data.collect{|a| a[:data].keys}.flatten.uniq.sort
    if a = @data.first
      data_labels.each do |k|
        if a[:data][k].nil?
          a[:data][k] = 0
        end
      end
      a[:data] = a[:data].sort.to_h
    end

    if !params[:user_id].blank?
      @user = User.find(params[:user_id])

      @records = @klass.where("updated_by_id": @user.id)
        .where(updated_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day)
        .order("#{@klass.table_name}.updated_at ASC")

      @records = @records.where(project_id: sessions_current_project_id) if !@klass.is_community?
      @sessions = ::Work.sessions(@records)
    end


  end

end
