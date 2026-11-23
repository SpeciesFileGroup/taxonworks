json.array!(@composition_items) do |composition_item|
  json.partial! 'attributes', composition_item:
end
