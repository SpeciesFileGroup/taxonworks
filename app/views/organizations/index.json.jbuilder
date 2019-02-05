json.array!(@otus) do |otu|
  json.partial! '/otus/attributes', otu: otu
end
