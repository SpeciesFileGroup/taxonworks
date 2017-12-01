class Keyword < ControlledVocabularyTerm 

  has_many :tags, foreign_key: :keyword_id, dependent: :destroy, inverse_of: :keyword, validate: true

  scope :used_on_klass, -> (klass) { joins(:tags).where(tags: {tag_object_type: klass} ) } # remember to .distinct 
  scope :used_recently, -> { select("controlled_vocabulary_terms.*, tags.created_at").joins(:tags).where(tags: { created_at: 1.weeks.ago..Time.now}).order('tags.created_at DESC') }

  def tagged_objects
    tags.collect{|t| t.tag_object}
  end

  def tagged_object_class_names
    tags.pluck(:tag_object_type)
  end

  def self.select_optimized(user_id, project_id, klass)
    h = {
      recent: Keyword.where(project_id: project_id).used_on_klass(klass).used_recently.limit(10).distinct.to_a,
      pinboard:  Keyword.pinned_by(user_id).where(project_id: project_id).to_a
    }

    h[:quick] = (Keyword.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a  + h[:recent][0..3]).uniq
    h
  end

end
