json.array! future do |o|
  json.extract! o, :cpl, :depth, :cplLabel
  json.otuLabel (o[:cpl].otu_id ? otu_tag(o[:cpl].otu) : nil)
end
