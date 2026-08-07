json.array!(@news) do |news|
  json.partial! '/news/api/v1/attributes', news:
end
