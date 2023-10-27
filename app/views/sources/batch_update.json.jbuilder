json.updated do
  json.array!(@result[:updated]) do |source|
    json.partial! '/sources/attributes', source:
  end
end

json.not_updated do
  json.array!(@result[:not_updated]) do |source|
    json.partial! '/sources/attributes', source:
  end
end
