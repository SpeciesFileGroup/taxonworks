class Predicate < ControlledVocabularyTerm

  include Shared::DwcOccurrenceHooks

  has_many :internal_attributes, inverse_of: :predicate, foreign_key: :controlled_vocabulary_term_id, dependent: :restrict_with_error
  scope :used_on_klass, -> (klass) { joins(:internal_attributes).where(data_attributes: {attribute_subject_type: klass}) }

  # @return [Scope]
  #    the max 10 most recently used predicates
  def self.used_recently(user_id, project_id, klass)
    t = InternalAttribute.arel_table
    p = Predicate.arel_table

    # i is a select manager
    i = t.project(t['controlled_vocabulary_term_id'], t['updated_at']).from(t)
      .where(t['updated_at'].gt( 10.weeks.ago ))
      .where(t['updated_by_id'].eq(user_id))
      .where(t['attribute_subject_type'].eq(klass))
      .where(t['project_id'].eq(project_id))
      .order(t['updated_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Predicate.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['controlled_vocabulary_term_id'].eq(p['id'])))
    ).pluck(:controlled_vocabulary_term_id).uniq
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

  def dwc_occurrences
    if ::DWC_ATTRIBUTE_URIS.values.flatten.include?(uri)

      a = Queries::DwcOccurrence::Filter.new(
        collection_object_query: {
          data_attribute_predicate_id: id
        }
      ).all

      b = Queries::DwcOccurrence::Filter.new(
        collecting_event_query: {
          data_attribute_predicate_id: id
        }
      ).all

      ::Queries.union(::DwcOccurrence, [a,b])
    else
      ::DwcOccurrence.none
    end
  end


end
