class ObservationMatrixRowItem::Single::Otu < ObservationMatrixRowItem::Single
 
  belongs_to :otu, inverse_of: :observation_matrix_row_items, class_name: '::Otu'

  validates_presence_of :otu
  validates_uniqueness_of :otu_id, scope: [:observation_matrix_id]

  def self.subclass_attributes
    [:otu_id]
  end

  def otus
    [otu].compact
  end

  def matrix_row_item_object
    otu 
  end
  
end
