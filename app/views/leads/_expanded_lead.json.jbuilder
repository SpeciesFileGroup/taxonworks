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

if extend_response_with('future_otus')
  json.futures do
    json.array! @futures do |future|
      json.partial! 'future_with_otus', future:
    end
  end
else
  json.futures @futures
end

json.ancestors @ancestors

# TODO yuk de/re-structuring to get extended otus
json.lead_item_otus do
  json.parent do
    json.array! @lead_item_otus[:parent] do |otu|
      json.partial! '/otus/attributes', otu:, extensions: false
    end
  end

  json.children @lead_item_otus[:children]
  #   json.array! @lead_item_otus[:children] do |c|
  #     json.array! c do |otu|
  #       json.partial! '/otus/attributes', otu:, extensions: false
  #     end
  #   end
  # end
end
