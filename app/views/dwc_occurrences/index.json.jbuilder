json.array!(@dwc_occurrences) do |dwc|
  json.merge! dwc.attributes.delete_if{|k,v| v.blank?}
end
