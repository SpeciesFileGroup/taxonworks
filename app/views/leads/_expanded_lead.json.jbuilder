root = @lead.root
child_has_descendant_lead_items =
  Lead.child_descendant_lead_item_flags(children: @children, root:)
json.root do
  json.partial! 'attributes', lead: root
end

json.lead do
  json.partial! 'attributes', lead: @lead
end

json.children do
  json.array! @children do |lead|
    if child_has_descendant_lead_items.nil?
      json.partial! 'attributes', lead:
    else
      json.partial! 'attributes',
        lead:,
        has_descendant_lead_items: child_has_descendant_lead_items.fetch(lead.id, false)
    end
  end
end

json.partial! 'lead_item_otus', lead_item_otus: @lead_item_otus, root:,
  extensions: false

if extend_response_with('ancestors_data')
  json.ancestors @lead.ancestors.reverse
end

if extend_response_with('future_otus')
  futures = @children&.map(&:future) || []
  json.futures do
    json.array! futures do |future|
      json.partial! 'future_with_otus', future:
    end
  end
elsif extend_response_with('futures_data')
  json.futures @children&.map(&:future) || []
end

if extend_response_with('key_data')
  metadata = key_metadata(root)
  json.key_metadata metadata
  json.key_ordered_parents metadata.keys
  json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
end

if extend_response_with('key_depictions')
  json.key_depictions key_depictions(@lead)
end
