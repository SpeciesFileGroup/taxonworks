json.array! future do |o|
  json.extract! o, :options, :depth, :optionsLabel
  json.otuLabel (o[:options].otu_id ? otu_tag(o[:options].otu) : nil)
end
