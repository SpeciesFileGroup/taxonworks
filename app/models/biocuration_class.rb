class BiocurationClass < ControlledVocabularyTerm
  include Shared::Taggable

  has_many :biocuration_classifications, inverse_of: :biocuration_class
  has_many :biological_collection_objects, through: :biocuration_classifications, class_name: 'CollectionObject::BiologicalCollectionObject', inverse_of: :biocuration_classes

  def taggable_with
    %w{BiocurationGroup}
  end

end
