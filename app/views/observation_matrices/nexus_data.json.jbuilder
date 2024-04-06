json.otus do
  json.array!(@nexus_data[:otus]) do |x|
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