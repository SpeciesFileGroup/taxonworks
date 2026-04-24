class Tasks::DataAttributes::FieldSynchronizeController < ApplicationController
  include TaskControllerConfiguration

  after_action -> { set_pagination_headers(:records) }, only: [:values], if: :json_request?

  def values
    if q = Queries::Query::Filter.instantiated_base_filter(params)
      if !q.params.empty?
        @attributes =  [params[:attribute]].flatten
        @records = q.all.order(params[:attribute]).page(params[:page]).per(params[:per])
        return
      end
    end
    render json: {}, status: :unprocessable_content
  end

end
