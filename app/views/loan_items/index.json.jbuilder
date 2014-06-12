json.array!(@loan_items) do |loan_item|
  json.extract! loan_item, :id, :loan_id, :collection_object_id, :date_returned, :collection_object_status, :position, :created_by_id, :updated_by_id, :project_id, :container_id
  json.url loan_item_url(loan_item, format: :json)
end
