json.leads do
  json.array! @leads do |lead|
    json.partial! 'attributes', lead:
  end
end

json.futures @futures
json.partial! 'lead_item_otus',
  lead_item_otus: @lead_item_otus, root: @leads.first.root