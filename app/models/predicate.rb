class Predicate < ControlledVocabularyTerm

  has_many :internal_attributes, inverse_of: :predicate, foreign_key: :controlled_vocabulary_term_id

  scope :used_on_klass, -> (klass) { joins(:internal_attributes).where(data_attributes: {attribute_subject_type: klass}) } 
  scope :used_recently, -> {  joins(:internal_attributes).where(data_attributes: { created_at: 1.weeks.ago..Time.now } ) }


  def self.select_optimized(user_id, project_id, klass)
    h = {
      recent: Predicate.where(project_id: project_id).used_on_klass(klass).used_recently.limit(10).distinct.to_a,
      pinboard:  Predicate.pinned_by(user_id).where(project_id: project_id).to_a
    }

    h[:quick] = (Predicate.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a  + h[:recent][0..3]).uniq
    h
  end

end
