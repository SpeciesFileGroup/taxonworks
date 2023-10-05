json.updated do
  json.array!(@result[:moved]) do |source|
    json.partial! '/sources/attributes', source:
  end
end

json.not_updated do
  json.array!(@result[:unmoved]) do |source|
    json.partial! '/sources/attributes', source:
  end
end
