class BiocurationClass < ControlledVocabularyTerm

  include Shared::Taggable

  has_many :biocuration_classifications
  has_many :biological_collection_objects, through: :biocuration_classifications, class_name: 'CollectionObject::BiologicalCollectionObject'

  def taggable_with
    %w{BiocurationGroup}
  end

end
