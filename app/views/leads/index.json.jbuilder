json.array!(@leads) do |lead|
  json.partial! 'attributes', lead:
end