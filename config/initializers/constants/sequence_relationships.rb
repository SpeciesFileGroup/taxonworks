# Be sure to restart your server (or console) when you modify this file.

# All SequenceRelationship subclasses

sequence_relationship_type_select = []

SequenceRelationship.descendants.each do |s|
  sequence_relationship_type_select.push([s.name.demodulize, s.to_s])
end

SEQUENCE_RELATIONSHIP_TYPE_SELECT = sequence_relationship_type_select.freeze