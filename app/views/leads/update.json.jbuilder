json.lead do
  json.partial! 'attributes', lead: @lead
end

if extend_response_with('future_otus')
  futures = @lead.children.map(&:future)
  json.futures do
    json.array! futures do |future|
      json.partial! 'future_with_otus', future:
    end
  end
elsif extend_response_with('futures_data')
  json.futures @lead.children.map(&:future)
end

if extend_response_with('key_data')
  root = @lead.root
  metadata = key_metadata(root)
  json.key_metadata metadata
  json.key_ordered_parents metadata.keys
  json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
end
