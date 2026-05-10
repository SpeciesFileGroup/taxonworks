json.array!(@dwc_occurrences) do |dwc|
  json.merge! dwc.attributes.slice(*::DwcOccurrence.target_columns.map(&:to_s)).compact_blank
end
