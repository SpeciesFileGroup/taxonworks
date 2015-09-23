module BiocurationClassificationsHelper
  def biocuration_classification_tag(biocuration_classification)
    return nil if biocuration_classification.nil?
    biocuration_classification.biocuration_class.name
  end
end
