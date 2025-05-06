json.extract! lead_item, :id, :lead_id, :otu_id, :project_id, :created_by_id, :updated_by_id, :position, :created_at, :updated_at
json.url lead_item_url(lead_item, format: :json)
