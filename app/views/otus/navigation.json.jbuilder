json.current_otu do
  json.partial! 'attributes', otu: @otu
end

json.parent_otus do
  json.array! parent_otus(@otu) do |o|
    json.id o.id
    json.name o.name
    json.object_tag otu_tag(o) 
  end
end

json.previous_otus do
  json.array! previous_otus(@otu) do |o|
    json.id o.id
    json.name o.name
    json.object_tag otu_tag(o) 
  end
end

json.next_otus do
  json.array! next_otus(@otu) do |o|
    json.id o.id
    json.name o.name
    json.object_tag otu_tag(o) 
  end
end

