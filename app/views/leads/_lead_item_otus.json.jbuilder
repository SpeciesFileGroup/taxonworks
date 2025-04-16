json.lead_item_otus do
  json.parent do
    json.array! @lead_item_otus[:parent] do |otu|
      json.partial! '/otus/attributes', otu:, extensions: false
    end
  end

  json.children @lead_item_otus[:children]
end