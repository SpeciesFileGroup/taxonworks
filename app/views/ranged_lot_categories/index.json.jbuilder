json.array!(@ranged_lot_categories) do |ranged_lot_category|
  json.extract! ranged_lot_category, :id, :name, :minimum_value, :maximum_value, :created_by_id, :updated_by_id, :project_id
  json.url ranged_lot_category_url(ranged_lot_category, format: :json)
end
