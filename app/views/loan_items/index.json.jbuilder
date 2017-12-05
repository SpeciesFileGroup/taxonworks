json.array!(@loan_items) do |loan_item|
  json.partial! 'attributes', loan_item: loan_item
end
