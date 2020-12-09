class ObservationMatrixColumnItem::Single::Descriptor < ObservationMatrixColumnItem::Single

  # This is not working for some reason
  # the base relationship should move here
  belongs_to :descriptor, inverse_of: :observation_matrix_column_items, class_name: '::Descriptor'
  
  validates_presence_of :descriptor
  
  validates_uniqueness_of :descriptor_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:descriptor_id]
  end

  def descriptors
    [descriptor].compact
  end

end

