class Tasks::CollectionObjects::Stepwise::DeterminationsController < ApplicationController
  include TaskControllerConfiguration
  after_action -> { set_pagination_headers(:collection_objects) }, only: [:data], if: :json_request?

  def index
  end

  def data
    s = ::Queries::CollectionObject::Filter.new(taxon_determinations: :false)
      .all
      .where(project_id: sessions_current_project_id)

    @collection_objects = ::CollectionObject.select('buffered_determinations, count(buffered_determinations) count_buffered').where('buffered_determinations is not null')
      .where(id: s.all)
      .group('buffered_determinations')
      .having('count(buffered_determinations) > ?', params[:count_cutoff] || 10)
      .order('count(buffered_determinations) DESC')
      .page(params[:page])
      .per(params[:per])

    render json: @collection_objects
  end
end
