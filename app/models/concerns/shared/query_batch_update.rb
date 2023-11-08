module Shared::QueryBatchUpdate

  extend ActiveSupport::Concern

  included do
  end

  def query_update(params, result)
    begin
      self.update!( params )
      result[:result][:passed] += 1
    rescue ActiveRecord::RecordInvalid => e
      result[:result][:failed] += 1
    end
    result
  end

  class_methods do

    def query_update(object, params, result)
      begin
        object.update!( params )
        result[:result][:passed].push object.id
      rescue ActiveRecord::RecordInvalid => e
        result[:result][:failed].push object.id
      end
    end

    # TODO: Should handle scope, not filter result (do that prior)
    # @return [Hash]
    def query_batch_update(params, limit: 100, async_cutoff: 26)
      r = {
        status: :ok,
        result: {
          queued: false,
          eta: nil,
          passed: [], # IDs that passed
          failed: [], # IDs that failed
          total: 0,
        }
      }

      k = self.name.demodulize.underscore.to_sym
      q = (k.to_s + '_query').to_sym

      if params[k].blank?
        r[:status] = :unprocessable_entity
        return r
      end

      query = "Queries::#{self.name}::Filter".safe_constantize

      a = query.new(params[q])

      c = a.all.count

      r[:result][:total] = c

      if c > limit
        r[:status] = :unprocessable_entity
        return r
      end

      if c < async_cutoff # Run sync
        r[:result][:eta] = 'Now'

        a.all.find_each do |o|
          query_update(o, params[k], r)
        end
      else # Run async
        r[:result][:queued] = true
        r[:result][:eta] = ApplicationController.helpers.distance_of_time_in_words(c.seconds)

        a.all.find_each do |o|
          o.delay(run_at: Proc.new { 1.second.from_now }, queue: :query_batch_update).query_update(params[k], r)
        end
      end

      return r
    end

  end

end
