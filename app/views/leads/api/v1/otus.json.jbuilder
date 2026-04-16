json.array! @otus do |otu|
  json.partial! '/otus/api/v1/attributes', otu:, extensions: false
end
