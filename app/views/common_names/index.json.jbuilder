json.array!(@common_names) do |common_name|
  json.partial! 'attributes', common_name: common_name
end
