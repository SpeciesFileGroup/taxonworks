class Tasks::CollectingEvents::Stepwise::CollectorsController < ApplicationController
  include TaskControllerConfiguration
  after_action -> { set_pagination_headers(:collecting_events) }, only: [:data], if: :json_request?

  def index
  end

  # GET
  def data
    s = ::Queries::CollectingEvent::Filter.new(collectors: :false)
                                          .all

    @collecting_events = ::CollectingEvent.select('verbatim_collectors, count(verbatim_collectors) count_collectors').where('verbatim_collectors is not null')
                                           .where(id: s.all)
                                           .group('verbatim_collectors')
                                           .having('count(verbatim_collectors) > ?', params[:count_cutoff] || 10)
                                           .order('count(verbatim_collectors) DESC')
                                           .page(params[:page])
                                           .per(params[:per])

    render json: @collecting_events
  end
end
