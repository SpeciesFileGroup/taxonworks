class Tasks::CollectionObjects::Stepwise::DeterminationsController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def data
    render json: CollectionObject.select('buffered_determinations, count(buffered_determinations) count_buffered').where('buffered_determinations is not null')
      .where(project_id: sessions_current_project_id)
      .group('buffered_determinations')
      .having('count(buffered_determinations) > ?', params[:count_cutoff] || 10)
      .order('count(buffered_determinations) DESC')
      .page(params[:page])
      .per(params[:per])
  end

end
