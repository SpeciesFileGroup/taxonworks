class Tasks::Accessions::Report::WorkController < ApplicationController
  include TaskControllerConfiguration
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # GET
  def index
  end

  def data
    @user = User.find(params[:user_id])

    @records = Queries::CollectionObject::Filter.new(
      user_target: 'updated',
      user_date_start: get_date('start'),
      user_date_end: get_date('end'),
      user_id: @user.id
    ).all.order('collection_objects.updated_at ASC')

    @sessions = ::Work.sessions(@records)
    render :index
  end

  def get_date(target)
    [
      params[target]['date(1i)'], 
      params[target]['date(2i)'], 
      params[target]['date(3i)'], 
    ].join('-')
  end

end
