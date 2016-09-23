json.array!(@extracts) do |extract|
  json.extract! extract, :id, :quantity_value, :quantity_unit, :concentration_value, :concentration_unit, :verbatim_anatomical_origin, :year_made, :month_made, :day_made, :created_by_id, :updated_by_id, :project_id
  json.url extract_url(extract, format: :json)
end
