# Shared endpoints that expose metadata about `Queries::*::Filter` classes.
# Currently just `#sortable_columns` -- the frontend calls this on filter
# task mount so it can hide sort buttons for columns the backend doesn't
# recognize, and stop adding sort keys past the backend's limit, avoiding
# dead clicks and silent no-ops.
class QueriesController < ApplicationController

  # GET /queries/:resource/sortable_columns.json
  # `resource` is the underscored resource name matching the Filter
  # subclass, e.g. 'collection_objects', 'biological_associations'.
  # Returns the sortable column keys, and the most keys a `sort` param
  # may use (the filter ignores any beyond that):
  #   { columns: ['updated_at', ...], max_sort_keys: 5 }
  def sortable_columns
    klass = filter_class_for(params[:resource])
    return render json: { columns: [], max_sort_keys: 0 }, status: :not_found unless klass

    render json: {
      columns: klass.sortable_columns_index,
      max_sort_keys: ::Queries::Query::Filter::MAX_SORT_KEYS
    }
  end

  private

  def filter_class_for(resource)
    return nil if resource.blank?
    name = "Queries::#{resource.to_s.classify}::Filter"
    klass = name.safe_constantize
    klass if klass && klass < ::Queries::Query::Filter
  end
end
