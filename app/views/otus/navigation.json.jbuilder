json.current_otu do
  json.partial! 'attributes', otu: @otu
end

json.parent_otus do
  json.array! parent_otus(@otu), partial:  'attributes', as: :otu
end

json.previous_otus do
  json.array! previous_otus(@otu), partial:  'attributes', as: :otu
end

json.next_otus do
  json.array! next_otus(@otu), partial:  'attributes', as: :otu
end

