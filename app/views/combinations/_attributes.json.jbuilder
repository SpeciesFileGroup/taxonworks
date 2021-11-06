json.partial! '/taxon_names/base_attributes', taxon_name: combination
json.partial! '/shared/data/all/metadata', object: combination, klass: 'Combination'

if extend_response_with('protonyms')
  json.protonyms do
    combination.combination_relationships.each do |r|
      json.set! r.rank_name do
        json.taxon_name_relationship_id r.id
        json.partial! '/taxon_names/attributes', taxon_name: r.subject_taxon_name 
      end
    end
  end
end

if extend_response_with('roles')
  if combination.roles.any?
    json.taxon_name_author_roles do
      json.array! combination.taxon_name_author_roles.each do |role|
        json.extract! role, :id, :position, :type
        json.person do
          json.partial! '/people/base_attributes', person: role.person
        end
      end
    end
  end
end

if extend_response_with('placement')
  # Metadata on the placement of the finest component of the Combination.
  # Used to update placement of names to a current placement.
  json.placement do
    json.same combination.is_current_placement?
    json.target_id combination.protonyms&.last&.id
    json.current_parent_id combination&.protonyms&.last&.parent_id
    json.new_parent_id combination.protonyms&.second_to_last&.id
  end
end
