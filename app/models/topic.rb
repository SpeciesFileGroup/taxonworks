# A Topic is a user defined subject.  It is used in conjuction with a citation on an OTU.
# Topics assert that "this source says something about this taxon on this topic."
#
class Topic < ControlledVocabularyTerm

  # TODO: Why?!
  include Shared::Tags

  has_many :citation_topics, inverse_of: :topic, dependent: :destroy
  has_many :citations, through: :citation_topics, inverse_of: :topics
  has_many :sources, through: :citations, inverse_of: :topics
  has_many :citation_objects, through: :citations, source_type: 'Citation'
  has_many :contents, inverse_of: :topic, dependent: :destroy
  has_many :public_contents, inverse_of: :topic, dependent: :destroy
  has_many :otus, through: :contents

  # TODO: Layout handling as a concern
  has_many :otu_page_layout_sections, -> {
    where(otu_page_layout_sections:
          {type: 'OtuPageLayoutSection::StandardSection'}) }, inverse_of: :topic
  has_many :otu_page_layouts, through: :otu_page_layout_sections

  scope :used_on_klass, -> (klass) { joins(:citations).where(citations: {citation_object_type: klass}) }

  # TODO: Deprecate for CVT + params (if not already done)
  def self.find_for_autocomplete(params)
    term = "#{params[:term]}%"
    where_string = "name LIKE '#{term}' OR name ILIKE '%#{term}' OR name = '#{term}' OR definition ILIKE '%#{term}'"
    ControlledVocabularyTerm.where(where_string).where(project_id: params[:project_id], type: 'Topic')
  end

  # @param used_on [String] one of `Citation` (default) or `Content`
  # @return [Scope]
  #    the max 10 most recently used topics, as used on Content or Citation
  def self.used_recently(user_id, project_id, klass, used_on = 'Citation')
    t = case used_on
        when 'Citation'
          CitationTopic.arel_table
        when 'Content'
          Content.arel_table
        end

    p = Topic.arel_table

    # i is a select manager
    i = t.project(t['topic_id'], t['updated_at']).from(t)
      .where(t['updated_at'].gt(10.weeks.ago))
      .where(t['updated_by_id'].eq(user_id))
      .where(t['project_id'].eq(project_id))
      .order(t['updated_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    if klass.blank?
      Topic.joins(
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['topic_id'].eq(p['id'])))
      ).pluck(:id).uniq
    else
      Topic.used_on_klass(klass).joins(
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['topic_id'].eq(p['id'])))
      ).pluck(:id).uniq
    end
  end

  # @params klass [String] if target is `Citation` then if provided limits to those classes with citations,
  # if `Content` then not used
  # @params target [String] one of `Citation` or `Content`
  # @params klass [String] like TaxonName, required if target == `Citation`
  # @return [Hash] topics optimized for user selection
  def self.select_optimized(user_id, project_id, klass, target = 'Citation')
    r = used_recently(user_id, project_id, klass, target)
    h = {
        quick: [],
        pinboard: Topic.pinned_by(user_id).where(project_id: project_id).to_a,
        recent: []
    }

    if r.empty?
      h[:quick] = Topic.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Topic.where('"controlled_vocabulary_terms"."id" IN (?)', r.first(10) ).order(:name).to_a
      h[:quick] = (Topic.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
          Topic.where('"controlled_vocabulary_terms"."id" IN (?)', r.first(5) ).order(:name).to_a +
          Topic.where(project_id: project_id, created_by_id: user_id, updated_at: (3.hours.ago..Time.now)).limit(5).to_a).uniq
    end

    h
  end

end
