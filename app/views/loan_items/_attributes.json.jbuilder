json.extract! loan_item, :id, :loan_id, :date_returned,  :position, :created_by_id, :updated_by_id, :project_id, :loan_item_object_id, :loan_item_object_type, :total, :disposition, :created_at, :updated_at
json.object_tag loan_item_tag(loan_item)
json.url loan_item_url(loan_item, format: :json)
json.global_id loan_item.to_global_id.to_s
