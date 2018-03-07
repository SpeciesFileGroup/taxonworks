json.array!(@notes) do |note|
  json.partial! 'attributes', note: note
end
