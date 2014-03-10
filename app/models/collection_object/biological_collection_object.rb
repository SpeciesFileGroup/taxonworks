class CollectionObject::BiologicalCollectionObject < CollectionObject
  has_many :otus, through: :taxon_determinations
  has_many :taxon_determinations

  has_many :biocuration_classifications
  has_many :biocuration_classes, through: :biocuration_classifications

  accepts_nested_attributes_for :biocuration_classes, :biocuration_classifications, :taxon_determinations, :otus

  def current_determination
    taxon_determinations.first
  end

  def reorder_determinations_by(attribute = :date)
    determinations = []
    if attribute == :date
      byebug 
      determinations = taxon_determinations.sort{|a, b| a.sort_date <=> b.sort_date }
    else
      determinations = taxon_determinations.order(attribute)
    end

    determinations.each_with_index do |td, i|
      td.update(position:  i)
    end
  end

end
