json.array! future do |o|
  json.extract! o, :lead, :depth, :leadLabel
  json.otuLabel (o[:lead].otu_id ? otu_tag(o[:lead].otu) : nil)
end
