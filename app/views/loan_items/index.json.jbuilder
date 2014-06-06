json.array!(@loan_items) do |loan_item|
  json.extract! loan_item, :id
  json.url loan_item_url(loan_item, format: :json)
end
