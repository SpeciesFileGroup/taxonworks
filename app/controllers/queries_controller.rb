# Authored with assistance from Claude (Anthropic)
#
# Shared endpoints that expose metadata about `Queries::*` classes.
# Currently just `#sortable_columns` -- the frontend calls this on filter
# task mount so it can hide sort buttons for columns the backend doesn't
# recognize, and stop adding sort keys past the backend's limit, avoiding
# dead clicks and silent no-ops.
class QueriesController < ApplicationController
  before_action :require_sign_in_and_project_selection

  # GET /queries/:resource/sortable_columns.json
  # `resource` is the underscored resource name of a model with a filter,
  # e.g. 'collection_objects', 'biological_associations'.
  # Returns the sort keys, and the most keys a `sort` param may use
  # (Queries::Pager ignores any beyond that):
  #   { columns: ['updated_at', ...], max_sort_keys: 5 }
  def sortable_columns
    sort = sort_class_for(params[:resource])
    return render json: { columns: [], max_sort_keys: 0 }, status: :not_found unless sort

    render json: {
      columns: sort.keys,
      max_sort_keys: ::Queries::Pager::MAX_SORT_KEYS
    }
  end

  private

  def sort_class_for(resource)
    return nil if resource.blank?
    name = resource.to_s.classify
    filter = "Queries::#{name}::Filter".safe_constantize
    return nil unless filter && filter < ::Queries::Query::Filter

    ::Queries::Sort::Base.for(filter.referenced_klass)
  end
end
