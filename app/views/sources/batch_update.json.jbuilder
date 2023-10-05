json.moved do
  json.array!(@result[:moved]) do |source|
    json.partial! '/sources/attributes', source: 
  end
end

json.unmoved do
  json.array!(@result[:unmoved]) do |source|
    json.partial! '/sources/attributes', source: 
  end
end

