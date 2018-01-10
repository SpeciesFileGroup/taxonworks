[:genus, :subgenus, :species, :subspecies].each do |r|
  json.set! r do
    json.array! @result[r] do |t|
      json.foo 'bar'
      json.partial! '/taxon_names/attributes', taxon_name: t
    end
  end
end



