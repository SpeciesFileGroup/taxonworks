json.array!(@ranged_lot_categories) do |ranged_lot_category|
  json.extract! ranged_lot_category, :id
  json.url ranged_lot_category_url(ranged_lot_category, format: :json)
end
