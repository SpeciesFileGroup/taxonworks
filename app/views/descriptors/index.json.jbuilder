json.array!(@descriptors) do |descriptor|
  json.partial! '/descriptors/attributes', descriptor: descriptor
end
