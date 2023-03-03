json.extract! descriptor, :id, :name, :short_name, :description, :default_unit,
  :type, :position, :description_name, :key_name, :weight,
  :gene_attribute_logic,
  :position,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: descriptor, url_base: :descriptor

# TODO: use extend
if descriptor.qualitative?
  json.character_states do 
    json.array! descriptor.character_states.order(:position) do |character_state|
      json.partial! '/character_states/attributes', character_state: character_state
    end
  end
end

# TODO: use extend
if descriptor.gene?
  json.gene_attributes do
    json.array! descriptor.gene_attributes do |gene_attribute|
      json.partial! '/gene_attributes/attributes', gene_attribute: gene_attribute 
    end
  end
end
