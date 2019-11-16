class Keyword < ControlledVocabularyTerm 

  has_many :tags, foreign_key: :keyword_id, dependent: :destroy, inverse_of: :keyword, validate: true

  scope :used_on_klass, -> (klass) { joins(:tags).where(tags: {tag_object_type: klass} ) } # remember to .distinct 

  # @return [Scope]
  #    the max 10 most recently used keywords
  def self.used_recently
    t = Tag.arel_table
    k = Keyword.arel_table 

    # i is a select manager
    i = t.project(t['keyword_id'], t['created_at']).from(t)
      .where(t['created_at'].gt( 1.weeks.ago ))
      .order(t['created_at'])
      .take(10)
      .distinct

    # z is a table alias 
    z = i.as('recent_t')

    Keyword.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['keyword_id'].eq(k['id'])))
    )
  end

  def tagged_objects
    tags.collect{|t| t.tag_object}
  end

  def tagged_object_class_names
    tags.pluck(:tag_object_type)
  end

  def self.select_optimized(user_id, project_id, klass)
    n = klass.tableize.to_sym
    h = {
      recent: (
        Keyword.where(project_id: project_id, created_by_id: user_id, created_at: 1.day.ago..Time.now)
        .limit(5)
        .order(:name).to_a +
        Keyword.joins(:tags)
        .where(project_id: project_id, tags: {updated_by_id: user_id})
        .used_on_klass(klass)
        .used_recently.limit(5)
        .distinct.to_a ).uniq, 

      pinboard: Keyword.pinned_by(user_id).where(project_id: project_id).to_a
    }

    h[:quick] = (Keyword.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a  + h[:recent][0..3]).uniq
    h
  end

end
