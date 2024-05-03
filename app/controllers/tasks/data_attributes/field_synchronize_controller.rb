class Tasks::DataAttributes::FieldSynchronizeController < ApplicationController
  include TaskControllerConfiguration

  after_action -> { set_pagination_headers(:records) }, only: [:values], if: :json_request?

  def values
    if q = Queries::Query::Filter.instatiated_base_filter(params)
      if !q.params.empty?
        @records = q.all.select(:id, *params[:attribute]).order(params[:attribute]).page(params[:page]).per(params[:per])
        render json: @records.to_json and return
      end
    end
    render json: {}, status: :unprocessable_entity
  end

end
