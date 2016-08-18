class OriginRelationship < ActiveRecord::Base
  include Housekeeping
  
  belongs_to :old_object, polymorphic: true
  belongs_to :new_object, polymorphic: true

  VALID_ORIGINS = {
    # 'FieldObservation' => ['CollectionObject'],
    'CollectionObject' => ['CollectionObject'], 

  }


  
  validates_presence_of :old_object, :new_object


end
