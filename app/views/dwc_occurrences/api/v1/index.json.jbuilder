json.array!(@dwc_occurrences) do |dwc|
  # TODO: reconsider exposing user#id
  json.merge! dwc.attributes.delete_if{|k,v| v.blank? || %w{created_by_id updated_by_id}.include?(k) }
end
