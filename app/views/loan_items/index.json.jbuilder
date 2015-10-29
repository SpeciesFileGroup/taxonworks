json.array!(@loan_items) do |loan_item|
  json.extract! loan_item, :id, :loan_id, :date_returned, :collection_object_status, :position, :created_by_id, :updated_by_id, :project_id, :loan_item_object_id, :loan_item_object_type, :total
  json.url loan_item_url(loan_item, format: :json)
end
