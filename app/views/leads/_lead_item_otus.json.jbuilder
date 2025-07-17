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
