class ObservationMatrixColumnItem::SingleDescriptor < ObservationMatrixColumnItem

  belongs_to :descriptor
  
  validates_presence_of :descriptor
  validates_uniqueness_of :descriptor_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:descriptor_id]
  end

  def descriptors
    [self.descriptor]
  end
  
end

