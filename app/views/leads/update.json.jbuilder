json.lead do
  json.partial! 'attributes', lead: @lead
end

if extend_response_with('future_data')
  json.future @lead.future
end

if extend_response_with('key_data')
  root = @lead.root
  metadata = key_metadata(root)
  json.key_metadata metadata
  json.key_ordered_parents metadata.keys
  json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
end
