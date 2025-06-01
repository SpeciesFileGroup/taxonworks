module Shared::BatchByFilterScope
  extend ActiveSupport::Concern

  module ClassMethods
    def batch_by_filter_scope(
      filter_query: nil, mode: :add, params: nil, async_cutoff: 300,
      project_id: nil, user_id: nil
    )
      params = params.to_h.symbolize_keys

      r = ::BatchResponse.new(
        preview: false,
        method: "#{self.name} batch_by_filter_scope"
      )

      if filter_query.nil?
        r.errors['scoping filter not provided'] = 1
        return r
      end

      b = ::Queries::Query::Filter.instantiated_base_filter(filter_query)
      q = b.all(true)

      fq = ::Queries::Query::Filter.base_query_to_h(filter_query)

      r.klass =  b.referenced_klass.name

      if b.only_project?
        r.total_attempted = 0
        r.errors['can not update records without at least one filter parameter'] = 1
        return r
      end

      c = q.count
      async = c > async_cutoff ? true : false

      # Careful, c is the count of model objects being processed, but there may be
      # multiple attributes processed per model object; in that case receivers
      # will need to update r.total_attempted as needed.
      r.total_attempted = c
      r.async = async

      r = self.process_batch_by_filter_scope(
        batch_response: r,
        query: q,
        hash_query: fq,
        mode:,
        params:,
        async:,
        project_id:,
        user_id:
      )

      r.to_json
    end

    def process_batch_by_filter_scope(
      batch_response, query, hash_query, mode, params, async_cutoff,
      project_id, user_id
    )
      raise TaxonWorks::Error, 'process_batch_by_filter_scope is not implemented!'
    end
  end

end
