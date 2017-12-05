json.extract! loan_item, :id, :loan_id, :date_returned,  :position, :created_by_id, :updated_by_id, :project_id, :loan_item_object_id, :loan_item_object_type, :total, :disposition, :created_at, :updated_at
json.object_tag loan_item_tag(loan_item)
json.url loan_item_url(loan_item, format: :json)
json.global_id loan_item.to_global_id.to_s

json.loan_item_object_tag object_tag(loan_item.loan_item_object)

if loan_item.loan_item_object_type == 'CollectionObject' && loan_item.loan_item_object.taxon_determinations.any?
  json.taxon_determination do
    json.partial! '/taxon_determinations/attributes', taxon_determination: loan_item.loan_item_object.taxon_determinations.order(:position).first
  end
end


