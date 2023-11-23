json.moved do
  json.array!(@result[:moved]) do |otu|
    json.partial! '/otus/attributes', otu:
  end
end

json.unmoved do
  json.array!(@result[:unmoved]) do |otu|
    json.partial! '/otus/attributes', otu:
  end
end

