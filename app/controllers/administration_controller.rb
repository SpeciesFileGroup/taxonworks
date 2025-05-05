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

    @data = []

    data = @klass.where("#{@klass.table_name}.#{@target} BETWEEN ? AND ?", @start_date, @end_date).distinct

    if @klass.column_names.include?('project_id')

      @projects.each do |u|
        d = {
          id: u.id,
          name: u.name
        }

        data = @klass.where("#{@klass.table_name}.#{@target} BETWEEN ? AND ?", @start_date, @end_date).distinct
        data = data.where(project_id: u)

        d[:data] = data.send("group_by_#{@time_span}", "#{@target}".to_sym ).count
        @data.push d
      end

    else
      d = {
        id: @klass.name,
        name: @klass.name
      }

      d[:data] = data.send("group_by_#{@time_span}", "#{@target}".to_sym ).count

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

    @aggregate_data = {}

    @data.each do |r|
      r[:data].each do |k, v|
        if @aggregate_data[k]
          @aggregate_data[k] += v
        else
          @aggregate_data[k] = v
        end
      end
    end

    @year_over_year = {}
    t = 0
    @aggregate_data.each do |k,v|
      t += v
      @year_over_year[k] = t
    end

  end

end
