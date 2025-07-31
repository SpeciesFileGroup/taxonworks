json.array! @otus do |otu|
  json.partial! '/otus/attributes', otu:, extensions: false
end
