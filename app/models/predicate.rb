class Predicate < ControlledVocabularyTerm

  has_many :internal_attributes, inverse_of: :predicate, foreign_key: :controlled_vocabulary_term_id, dependent: :restrict_with_error

  scope :used_on_klass, -> (klass) { joins(:internal_attributes).where(data_attributes: {attribute_subject_type: klass}) }

  # @return [Scope]
  #    the max 10 most recently used predicates
  def self.used_recently(user_id, project_id, klass)
    i = InternalAttribute.arel_table
    p = Predicate.arel_table

    # i is a select manager
    i = i.project(i['controlled_vocabulary_term_id'], i['updated_at']).from(i)
      .where(i['updated_at'].gt( 10.weeks.ago ))
      .where(i['updated_by_id'].eq(user_id))
      .where(i['project_id'].eq(project_id))
      .order(i['updated_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Predicate.used_on_klass(klass).joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['controlled_vocabulary_term_id'].eq(p['id'])))
    ).select('distinct controlled_vocabulary_terms.id').pluck(:id)
  end

  def self.select_optimized(user_id, project_id, klass)
    r = used_recently(user_id, project_id, klass).first(10)

    h = {
      quick: [],
      pinboard: Predicate.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = Predicate.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Predicate.where('"controlled_vocabulary_terms"."id" IN (?)', r[0..9] ).order(:name).to_a
      h[:quick] = (
        Predicate.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
        Predicate.where('"controlled_vocabulary_terms"."id" IN (?)', r[0..3] ).order(:name).to_a).uniq
    end

    h
  end

end
