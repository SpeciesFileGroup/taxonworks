# Shared code for Citations.
#
#  The default behaviour with order by youngest source and oldest source is to place records with NIL *last*
# in the list.
#  When multiple citations exist the earliest or latest is used in the sort order.
#
module Shared::Citations
  extend ActiveSupport::Concern

  included do
    related_class = self.name
    related_table_name = self.table_name

    Citation.related_foreign_keys.push self.name.foreign_key

    # !! Validate: true assigns housekeeping where needed (!don't make this self-referential!)
    has_many :citations, as: :citation_object, dependent: :destroy, inverse_of: :citation_object, validate: true
    has_many :citation_topics, through: :citations, validate: true
    has_many :topics, through: :citation_topics, validate: true

    has_many :subsequent_citations, -> { where(is_original: nil) }, as: :citation_object, class_name: 'Citation'

    has_many :sources, -> { distinct }, through: :citations, inverse_of: :citations
    has_many :subsequent_sources, -> { distinct },  through: :subsequent_citations, source: :source

    has_one :origin_citation, -> {where(is_original: true)}, as: :citation_object, class_name: 'Citation', inverse_of: :citation_object

    has_one :source, through: :origin_citation, inverse_of: :origin_citations

    scope :without_citations, -> {includes(:citations).where(citations: {id: nil})}

    # LLM generated optimization on 2025/1/23 as "optimization of query"
    # Roughly 2x as fast in this incarnation.  See also `.youngest"
    scope :order_by_youngest_source_first, -> {
      joins("LEFT JOIN LATERAL (
        SELECT MAX(sources.cached_nomenclature_date) AS max_date
        FROM citations
        JOIN sources ON citations.source_id = sources.id
        WHERE citations.citation_object_id = #{related_table_name}.id AND citations.citation_object_type = '#{related_class}'
      ) AS max_dates ON TRUE")
        .order(Arel.sql("max_dates.max_date DESC NULLS LAST"))
    }

    scope :order_by_oldest_source_first, -> {
      joins("LEFT JOIN LATERAL (
        SELECT MIN(sources.cached_nomenclature_date) AS min_date
        FROM citations
        JOIN sources ON citations.source_id = sources.id
        WHERE citations.citation_object_id = #{related_table_name}.id AND citations.citation_object_type = '#{related_class}'
      ) AS min_dates ON TRUE")
        .order(Arel.sql("min_dates.min_date ASC NULLS LAST"))
    }

    accepts_nested_attributes_for :citations, reject_if: :reject_citations, allow_destroy: true
    accepts_nested_attributes_for :origin_citation, reject_if: :reject_citations, allow_destroy: true

    validate :origin_citation_source_id, if: -> { !new_record? }

    # !! use validate: true in associations settings to trigger this as needed
    # Required to trigger validate callbacks, which in turn set user_id related housekeeping
    # validates_associated :citations
  end

  class_methods do
    def oldest_by_citation
      order_by_oldest_source_first.to_a.first
    end

    # @return Object
    #   Assuming the scope returns something an object
    #   returns regardless if it has citations or not.
    def youngest_by_citation
      order_by_youngest_source_first.to_a.first
    end

    # @return Object, nil
    # !! Only returns an object if citations exist on objects in scope!
    # Far more performant than youngest_by_citation
    def youngest(scope)
      citations = Citation.with(objects: scope.select(:id))
        .joins(:source)
        .joins("JOIN objects o on o.id = citations.citation_object_id AND citations.citation_object_type = '#{base_class.name}'")
        .select('citations.id, sources.cached_nomenclature_date, citations.citation_object_type, citations.citation_object_id')

      citations.sort_by(&:cached_nomenclature_date)&.last&.citation_object
    end
    
  end

  # @return [Date, nil]
  # !! Over-riden in various places, but it shouldn't be
  # See Source::Bibtex for context as to how this is built.
  #
  def nomenclature_date
    self.class.joins(citations: [:source])
    .where(citations: {citation_object: self, is_original: true})
    .select('sources.cached_nomenclature_date')
    .first&.cached_nomenclature_date
  end

  alias_method :source_nomenclature_date, :nomenclature_date

  def origin_citation_source_id
    if origin_citation && origin_citation.source_id.blank?
      errors.add(:base, 'the origin citation must have a source')
    end
  end

  def sources_by_topic_id(topic_id)
    Source.joins(:citation_topics).where(citations: {citation_object: self}, citation_topics: {topic_id:})
  end

  # @return [Boolean]
  #   if at least one citation is required override this with true in including class
  def requires_citation?
    false
  end

  def cited?
    self.citations.any?
  end

  def mark_citations_for_destruction
    citations.map(&:mark_for_destruction)
  end

  protected

  def reject_citations(attributed)
    if (attributed['source_id'].blank? && attributed['source'].blank?)
      return true if new_record?
      return true if attributed['pages'].blank?
    end
    false
  end

end
