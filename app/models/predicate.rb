class Predicate < ControlledVocabularyTerm

  has_many :internal_attributes, inverse_of: :predicate, foreign_key: :controlled_vocabulary_term_id

  scope :used_on_klass, -> (klass) { joins(:internal_attributes).where(data_attributes: {attribute_subject_type: klass}) } 

  # @return [Scope]
  #    the max 10 most recently used predicates 
  def self.used_recently
    i = InternalAttribute.arel_table
    p = Predicate.arel_table

    # i is a select manager
    i = i.project(i['controlled_vocabulary_term_id'], i['created_at']).from(i)
      .where(i['created_at'].gt( 1.weeks.ago ))
      .order(i['created_at'])
      .take(10)
      .distinct

    # z is a table alias 
    z = i.as('recent_t')

    Predicate.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['controlled_vocabulary_term_id'].eq(p['id'])))
    )
  end

  def self.select_optimized(user_id, project_id, klass)
    h = {recent: (Predicate.joins(:internal_attributes).used_on_klass(klass)
      .used_recently
      .where(project_id: project_id, data_attributes: {created_by_id: user_id})
      .limit(10).distinct.to_a +
    Predicate.where(created_by_id: user_id, created_at: 3.hours.ago..Time.now).limit(5).to_a).uniq,
    pinboard:  Predicate.pinned_by(user_id).where(project_id: project_id).to_a
    }

    h[:quick] = (Predicate.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a  + h[:recent][0..3]).uniq
    h
  end

end
