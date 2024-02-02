json.extract! lead, :id, :parent_id, :otu_id, :text, :origin_label, :description, :redirect_id, :link_out, :link_out_text, :position, :is_public, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: lead

# TODO: metaphorphosize otu once we figure out what that references in the key (one step in the key or the entire key)
# TODO: can we include citation here?

#json.object_tag lead_tag(namespace)
#json.url lead_url(lead, format: :json)
#json.global_id lead.to_global_id.to_s
#json.type 'Namespace'
#json.url lead_url(lead, format: :json)
