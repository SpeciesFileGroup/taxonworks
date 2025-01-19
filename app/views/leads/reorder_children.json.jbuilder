json.leads do
  json.array! @leads do |lead|
    json.partial! 'attributes', lead:
  end
end

json.futures @futures