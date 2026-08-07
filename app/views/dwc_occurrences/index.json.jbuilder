json.array!(@dwc_occurrences) do |dwc|
  json.merge! format_dwc_occurrence_attributes_for_ui(
    dwc.attributes.select { |key, value| value.present? }
  )
end
