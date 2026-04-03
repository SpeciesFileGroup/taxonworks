json.array!(@dwc_occurrences) do |dwc|
  # TODO: reconsider exposing user#id
  json.merge! dwc.attributes.select { |key, value| value.present? && !%w{created_by_id updated_by_id}.include?(key) }
end
