json.array!(@descriptors) do |descriptor|
  json.partial! 'attributes', descriptor: descriptor
end
