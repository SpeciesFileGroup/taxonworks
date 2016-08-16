class ConfidenceLevel < ControlledVocabularyTerm

  has_many :confidences, as: :confidence_object, dependent: :destroy

  scope :for_confidences, -> { where(type: 'ConfidenceLevel') }

  def confidenced_objects
    self.confidences.collect{|c| c.confidence_object}
  end

  def confidenced_object_class_names
    Confidence.where(confidence_level: self).pluck(:confidence_object_type)
  end
end
