# A user-defined level of data quality vi Confidences.  
class ConfidenceLevel < ControlledVocabularyTerm
  has_many :confidences, foreign_key: :confidence_level_id, dependent: :destroy, inverse_of: :confidence_level

  scope :used_on_klass, -> (klass) { joins(:confidences).where(confidences: {confidence_object_type: klass} ) } 
  scope :used_recently, -> { select("controlled_vocabulary_terms.*, confidences.created_at").joins(:confidences).where(confidences: { created_at: 1.weeks.ago..Time.now}).order('confidences.created_at DESC') }

  def confidenced_objects
    confidences.collect{|c| c.confidence_object}
  end

  def confidenced_object_class_names
    Confidence.where(confidence_level: self).pluck(:confidence_object_type)
  end

  def self.select_optimized(user_id, project_id, klass)
    h = {
      recent: ConfidenceLevel.where(project_id: project_id).used_on_klass(klass).used_recently.distinct.limit(10).to_a,
      pinboard:  ConfidenceLevel.pinned_by(user_id).where(project_id: project_id).to_a
    }

    h[:quick] = (ConfidenceLevel.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a + h[:recent][0..3]).uniq
    h
  end

end
