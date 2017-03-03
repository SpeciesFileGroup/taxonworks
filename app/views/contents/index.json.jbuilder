json.array!(@contents) do |content|
  json.partial! '/contents/attributes', content: content 
end
