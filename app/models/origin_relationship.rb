class OriginRelationship < ActiveRecord::Base
  include Housekeeping
  
  belongs_to :old_object, polymorphic: true # Source of new object
  belongs_to :new_object, polymorphic: true # Comes from the old objet, result

=begin
old_object              new_object
 
(field_observation / collection_object)

(collection_object / collection_object)

(collection_object / "extract")

(collection_object / part_of (anatomy)

(part_of / part_of )

(part_of / extract)

(extract / extract)

(extract / sequence)

(sequence / sequence)
=end

  VALID_ORIGINS = {
    # 'FieldObservation' => ['CollectionObject'],
    'CollectionObject' => ['CollectionObject'], 

  }


  # Don't validate presence of old_object or new_object
  # so that nested attributes can work in such a way where
  # the old_object and new_object don't have to be saved first
  # validates_presence_of :old_object, :new_object


end
