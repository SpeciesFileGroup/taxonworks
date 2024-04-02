# Facilitate batch updates that use a BatchQueryRequest
#
module Shared::QueryBatchUpdate

  extend ActiveSupport::Concern

  included do
  end

  # @params params [Hash]
  #   the attributes to update
  # @params result [BatchResponse]
  def query_update(params, response)
    begin
      update!( params )
      response.updated.push self.id
    rescue ActiveRecord::RecordInvalid => e
      response.not_updated.push e.record.id
      response.errors[e.message] += 1
    end
  end

  class_methods do

    # @return [BatchResponse, false]
    def query_batch_update(request)
      return false if request.unprocessable?

      r = request.stub_response
      r.method = 'query_batch_update'

      a = request.filter

      if request.run_async?
        a.all.find_each do |o|
          o.delay(run_at: Proc.new { 1.second.from_now }, queue: :query_batch_update).query_update(request.object_params, r)
        end
      else
        self.transaction do
          a.all.find_each do |o|
            query_update(o, request.object_params, r)
          end
          raise ActiveRecord::Rollback if request.preview
        end
      end

      r
    end

    def query_update(object, params, response)
      raise ArgumentError if object.nil? || response.nil? || params.empty?
      begin
        object.update!( params )
        response.updated.push object.id
      rescue ActiveRecord::RecordInvalid => e
        response.not_updated.push e.record.id
        response.errors[e.message] += 1
      end
    end

  end # END CLASS METHODS
end
