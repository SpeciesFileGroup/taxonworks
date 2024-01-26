json.extract! lead, :id, :parent_id, :otu_id, :text, :origin_label, :description, :redirect_id, :link_out, :link_out_text, :position, :is_public, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at
json.url lead_url(lead, format: :json)
