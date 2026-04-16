json.otus do
  json.array!(@otus) do |x|
    if x.is_a? String
      json.name x
    else
      json.otu do
        json.partial! '/otus/attributes', otu: x, extensions: false
      end
      json.taxon_name do
        x['tname']
      end
    end
  end
end

json.descriptors do
  json.array!(@descriptors) do |x|
    if x.is_a? String
      json.name x
    else
      json.descriptor do
        json.partial! '/descriptors/attributes', descriptor: x
      end
    end
  end
end