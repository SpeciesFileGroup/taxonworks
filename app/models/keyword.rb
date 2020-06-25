class Keyword < ControlledVocabularyTerm 

  has_many :tags, foreign_key: :keyword_id, dependent: :destroy, inverse_of: :keyword, validate: true

  scope :used_on_klass, -> (klass) { joins(:tags).where(tags: {tag_object_type: klass} ) } # remember to .distinct 

  # @return [Scope]
  #    the max 10 most recently used keywords
  def self.used_recently(user_id, project_id, klass)
    t = Tag.arel_table
    k = Keyword.arel_table 

    # i is a select manager
    i = t.project(t['keyword_id'], t['created_at']).from(t)
      .where(t['created_at'].gt( 1.weeks.ago ))
      .where(t['created_by_id'].eq(user_id))
      .where(t['project_id'].eq(project_id))
      .order(t['created_at'].desc)

    # z is a table alias 
    z = i.as('recent_t')

    Keyword.used_on_klass(klass).joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['keyword_id'].eq(k['id'])))
    ).pluck(:id).uniq
  end

  def tagged_objects
    tags.collect{|t| t.tag_object}
  end

  def tagged_object_class_names
    tags.pluck(:tag_object_type)
  end

  def self.select_optimized(user_id, project_id, klass)
    r = used_recently(user_id, project_id, klass)
    h = {
        quick: [],
        pinboard: Keyword.pinned_by(user_id).where(project_id: project_id).to_a,
        recent: []
    }

    if r.empty?
      h[:quick] = Keyword.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Keyword.where('"controlled_vocabulary_terms"."id" IN (?)', r.first(10) ).order(:name).to_a
      h[:quick] = (Keyword.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
          Keyword.where('"controlled_vocabulary_terms"."id" IN (?)', r.first(4) ).order(:name).to_a).uniq
    end

    h
  end

end
