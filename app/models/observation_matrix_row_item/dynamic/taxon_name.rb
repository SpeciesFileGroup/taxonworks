# The intent is to capture all OTUs linked through a TaxonName Hierarchy
class ObservationMatrixRowItem::Dynamic::TaxonName < ObservationMatrixRowItem::Dynamic

  belongs_to :taxon_name, inverse_of: :observation_matrix_row_items, class_name: '::TaxonName'

  validates_presence_of :taxon_name_id
  validates_absence_of :controlled_vocabulary_term_id
  validates_uniqueness_of :taxon_name_id, scope: [:observation_matrix_id, :project_id]

  def self.subclass_attributes
    [:taxon_name_id]
  end

  def row_objects
    ::Otu.joins(:taxon_name).where(taxon_name: taxon_name.self_and_descendants).to_a
  end

  def matrix_row_item_object
    taxon_name 
  end

  # @params taxon_name_id required
  # @params otu_id required
  #   Remove all OTU rows for row items attached to this ID or others
  def self.cleanup(taxon_name_id, otu_id)
    to_check = ::TaxonName.find(taxon_name_id).self_and_ancestors.pluck(:id)
    self.where(taxon_name_id: to_check).each do |mri|
      mri.update_matrix_rows
    end 
  end

end
