json.array!(@common_names) do |common_name|
  json.partial! '/common_names/api/v1/attributes', common_name: common_name
end
