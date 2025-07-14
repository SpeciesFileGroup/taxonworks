json.partial! 'expanded_lead', lead: @lead, children: @children,
  futures: @futures, ancestors: @ancestors, lead_item_otus: @lead_item_otus

if extend_response_with('key_data')
  root = @lead.root
  metadata = key_metadata(root)
  json.key_metadata metadata
  json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
end