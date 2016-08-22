class MatrixRowItem::SingleOtu < MatrixRowItem

  belongs_to :otu

  validates_presence_of :otu_id
  validates_uniqueness_of :otu_id, scope: [:matrix_id]

  def self.subclass_attributes
    [:otu_id]
  end

  def otus
    [self.otu]
  end
end