json.array!(@contents) do |content|
  json.partial! '/contents/api/v1/attributes', content: content 
end
