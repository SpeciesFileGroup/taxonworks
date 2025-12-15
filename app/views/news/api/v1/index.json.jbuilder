json.array!(@news) do |news|
  json.partial! '/news/attributes', news: 
end
