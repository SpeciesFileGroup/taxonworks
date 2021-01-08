json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: combination

json.protonyms do
  combination.combination_relationships.each do |r|
    json.set! r.rank_name do
      json.partial! '/taxon_names/api/v1/attributes', taxon_name: r.subject_taxon_name 
    end
  end
end

# Metadata on the placement of the finest component of the Combination.
# Used to update placement of names to a current placement.
json.placement do
  json.same combination.is_current_placement?
  json.target_id combination.protonyms&.last&.id
  json.current_parent_id combination&.protonyms&.last&.parent_id
  json.new_parent_id combination.protonyms&.second_to_last&.id
end

# TODO: move to shared
# if combination.origin_citation
#   json.origin_citation do
#     json.partial! '/citations/attributes', citation: combination.origin_citation
#   end
# end
