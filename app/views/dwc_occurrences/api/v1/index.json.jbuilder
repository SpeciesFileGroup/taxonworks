json.array!(@dwc_occurrences) do |dwc|
  json.merge! dwc.api_attributes
end
