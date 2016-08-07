class MatrixColumnItem::SingleDescriptor < MatrixColumnItem 

  belongs_to :descriptor
  
  validates_presence_of :descriptor_id
  validates_uniqueness_of :descriptor_id, scope: [:matrix_id]

  def self.subclass_attributes
    [:descriptor_id]
  end

  def descriptors
    [self.descriptor]
  end
  
end

