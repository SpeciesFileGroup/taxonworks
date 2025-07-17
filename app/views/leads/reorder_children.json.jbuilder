json.leads do
  json.array! @leads do |lead|
    json.partial! 'attributes', lead:
  end
end

json.partial! 'lead_item_otus',
  lead_item_otus: @lead_item_otus, root: @leads.first.root

if extend_response_with('futures_data')
  json.futures @futures
end

if extend_response_with('key_data')
  root = @lead.root
  metadata = key_metadata(root)
  json.key_metadata metadata
  json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
end