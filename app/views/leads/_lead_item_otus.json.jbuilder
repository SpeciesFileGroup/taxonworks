json.lead_item_otus do
  parent_otus = lead_item_otus[:parent].map do |otu|
    JSON.parse(render(
      partial: '/otus/attributes',
      locals: { otu:, extensions: false }
    ))
  end

  parent_otus.sort! { |a,b|
    a['object_label'] <=> b['object_label']
  }

  json.parent parent_otus

  parent_otu_ids = parent_otus.map { |otu| otu['id'] }
  json.children do
    json.array! lead_item_otus[:children] do |c|
      json.fixed c[:fixed]
      json.otu_indices  c[:otu_ids].map { |id| parent_otu_ids.find_index(id) }
    end
  end

end

extensions = true if extensions.nil?
if extensions
  if extend_response_with('future_data')
    json.future lead.future
  end

  if extend_response_with('key_data')
    root = root || lead.root
    metadata = key_metadata(root)
    json.key_metadata metadata
    json.key_ordered_parents metadata.keys
    json.key_data key_data(root, metadata, lead_items: true, back_couplets: true)
  end
end
