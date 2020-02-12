class ObservationMatrixRowItem::SingleOtu < ObservationMatrixRowItem

  belongs_to :otu

  validates_presence_of :otu
  validates_uniqueness_of :otu_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:otu_id]
  end

  def otus
    [self.otu]
  end

  def matrix_row_item_object
    otu 
  end
  
end
