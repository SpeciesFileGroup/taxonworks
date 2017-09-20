@taxon_name.original_combination_relationships_and_stubs.each do |relationship|
  if relationship.persisted?
    json.set! relationship.class.inverse_assignment_method do
      json.partial!('/taxon_name_relationships/attributes', taxon_name_relationship: relationship)
    end
  end
end


