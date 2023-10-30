module Shared::QueryBatchUpdate

  extend ActiveSupport::Concern

  included do
  end

  class_methods do

    def query_update(object, params)
      begin
        object.update!( params )
      rescue ActiveRecord::RecordInvalid => e
      end
    end

    handle_asynchronously :query_update, run_at: Proc.new { 1.second.from_now }, queue: :query_batch_update

    # Should be scope batch update really...
    # @return [Hash, false]
    def query_batch_update(params, limit: 100)
      k = self.name.demodulize.underscore.to_sym 
      q = (k.to_s + '_query').to_sym

      return false if params[k].blank?

      query = "Queries::#{self.name}::Filter".safe_constantize

      a = query.new(params[q])

      c = a.all.count
      return false if c > limit

      a.all.find_each do |o|
        query_update(o, params[k])
      end

      return true
    end

  end

end
