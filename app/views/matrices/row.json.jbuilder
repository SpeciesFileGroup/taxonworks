json.otu do |otu|
  otu.partial! '/otus/attributes', otu: @otu
end

json.descriptors do |descriptors|
  descriptors.array!(@descriptors) do |descriptor|
    descriptors.partial! '/descriptors/attributes', descriptor: descriptor
  end
end




