# Users must implement batch_by_filter_scop_params, which should require a
# `batch_params` key and permit batch parameters specific to the model.
module BatchByFilterScope
  extend ActiveSupport::Concern

  included do
    # POST
    def batch_by_filter_scope
      klass = controller_path.classify.constantize

      r = klass.batch_by_filter_scope(
        filter_query: params.require(:filter_query), # like filter_query: { otu_query: {} }
        params: batch_by_filter_scope_params.to_h.symbolize_keys,
        mode: params.require(:mode),
        project_id: sessions_current_project_id,
        user_id: sessions_current_user_id
      )

      if r[:errors].empty?
        render json: r.to_json, status: :ok
      else
        render json: r.to_json, status: :unprocessable_entity
      end

    end

  end

  def batch_by_filter_scope_params
    raise TaxonWorks::Error, 'batch_by_filter_scope_params is undefined!'
    # e.g.
    # params.require(:batch_params).permit(:namespace_id, identifier_types: [])
  end
end
