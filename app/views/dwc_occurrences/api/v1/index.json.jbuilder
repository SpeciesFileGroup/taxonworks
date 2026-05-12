json.array!(@dwc_occurrences) do |dwc|
  json.merge! dwc.attributes.slice(*::DwcOccurrence.api_columns).compact_blank
end
