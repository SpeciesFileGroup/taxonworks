class Tasks::CollectionObjects::Stepwise::DeterminationsController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def data
    s = ::Queries::CollectionObject::Filter.new(
      taxon_determinations: false,
      project_id: sessions_current_project_id
    )

    render json: CollectionObject.select('buffered_determinations, count(buffered_determinations) count_buffered').where('buffered_determinations is not null')
      .where(id: s.all)
      .group('buffered_determinations')
      .having('count(buffered_determinations) > ?', params[:count_cutoff] || 10)
      .order('count(buffered_determinations) DESC')
      .page(params[:page])
      .per(params[:per])
  end

end
