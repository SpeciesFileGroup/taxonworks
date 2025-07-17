json.root do
  if @ancestors.length == 0
    json.partial! 'attributes', lead: @lead
  else
    json.partial! 'attributes', lead: @ancestors[0]
  end
end

json.lead do
  json.partial! 'attributes', lead: @lead
end

json.children do
  json.array! @children do |lead|
    json.partial! 'attributes', lead:
  end
end

json.partial! 'lead_item_otus', lead_item_otus: @lead_item_otus, root: @lead.root

if extend_response_with('ancestors_data')
  json.ancestors @ancestors
end

if extend_response_with('future_otus')
  json.futures do
    json.array! @futures do |future|
      json.partial! 'future_with_otus', future:
    end
  end
elsif extend_response_with('futures_data')
  json.futures @futures
end

if extend_response_with('key_data')
  root = @lead.root
  metadata = key_metadata(root)
  json.key_metadata metadata
  json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
end