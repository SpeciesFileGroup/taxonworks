# A user-defined level of data quality vi Confidences.  
class ConfidenceLevel < ControlledVocabularyTerm
  has_many :confidences, foreign_key: :confidence_level_id, dependent: :destroy, inverse_of: :confidence_level

  scope :used_on_klass, -> (klass) { joins(:confidences).where(confidences: {confidence_object_type: klass} ) }

  # @return [Scope]
  #    the max 10 most recently used confidence levels
  def self.used_recently
    t = ConfidenceLevel.arel_table 
    c = Confidence.arel_table

    # i is a select manager
    i = c.project(c['confidence_level_id'], c['created_at']).from(c)
      .where(c['created_at'].gt( 1.weeks.ago ))
      .order(c['created_at'])
     
    # z is a table alias 
    z = i.as('recent_c')

    ConfidenceLevel.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['confidence_level_id'].eq(t['id'])))
    ).distinct.limit(10)
  end

  def confidenced_objects
    confidences.collect{|c| c.confidence_object}
  end

  def confidenced_object_class_names
    Confidence.where(confidence_level: self).pluck(:confidence_object_type)
  end

  # @param klass [like CollectionObject] required
  def self.select_optimized(user_id, project_id, klass)
    h = {
      recent: ConfidenceLevel.used_on_klass(klass).used_recently.where(project_id: project_id, confidences: {updated_by_id: user_id}).distinct.limit(10).to_a,
      pinboard:  ConfidenceLevel.pinned_by(user_id).where(project_id: project_id).to_a
    }

    h[:quick] = (ConfidenceLevel.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a + h[:recent][0..3]).uniq
    h
  end

end
