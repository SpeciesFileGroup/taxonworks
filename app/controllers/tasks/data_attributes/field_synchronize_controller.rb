class Tasks::DataAttributes::FieldSynchronizeController < ApplicationController
  include TaskControllerConfiguration

  def values
    if q = Queries::Query::Filter.instatiated_base_filter(params)
      if !q.params.empty?
        render json: q.all.select(:id, *params[:attribute]).to_json and return
      end
    end
    render json: {}, status: :unprocessable_entity
  end

end
