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
