root = @lead.root

json.leads do
  json.array! @leads do |lead|
    json.partial! 'attributes', lead:
  end
end

json.partial! 'lead_item_otus',
  lead_item_otus: @lead_item_otus, root: root

if extend_response_with('future_otus')
  futures = @leads&.map(&:future) || []
  json.futures do
    json.array! futures do |future|
      json.partial! 'future_with_otus', future:
    end
  end
elsif extend_response_with('futures_data')
  json.futures @leads&.map(&:future) || []
end

if extend_response_with('key_data')
  metadata = key_metadata(root)
  json.key_metadata metadata
  json.key_ordered_parents metadata.keys
  json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
end