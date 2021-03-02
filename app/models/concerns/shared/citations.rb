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

    has_many :citations, as: :citation_object, validate: false, dependent: :destroy
    has_many :citation_topics, through: :citations
    has_many :topics, through: :citation_topics

    has_many :subsequent_citations, -> { where(is_original: nil) }, as: :citation_object, class_name: 'Citation'

    has_many :sources, -> { distinct }, through: :citations
    has_many :subsequent_sources, -> { distinct },  through: :subsequent_citations, source: :source

    has_one :origin_citation, -> {where(is_original: true)}, as: :citation_object, class_name: 'Citation'
    has_one :source, through: :origin_citation

    scope :without_citations, -> {includes(:citations).where(citations: {id: nil})}

    # scope :order_by_youngest_source_first, -> {
    #  joins("LEFT OUTER JOIN citations on #{related_table_name}.id = citations.citation_object_id
    # LEFT OUTER JOIN sources ON citations.source_id = sources.id").
    #  group("#{related_table_name}.id").order("MAX(COALESCE(sources.cached_nomenclature_date,
    # Date('1-1-0001'))) DESC").
    #  where("((citations.citation_object_type = '#{related_class}') OR (citations.citation_object_type is null))")
    # }

    scope :order_by_youngest_source_first, -> {
      join_str = ActiveRecord::Base.send(
        :sanitize_sql_array,
        ["LEFT OUTER JOIN citations ON #{related_table_name}.id = " \
         'citations.citation_object_id ' \
         'AND citations.citation_object_type = ? LEFT OUTER JOIN sources ' \
         'ON citations.source_id = sources.id',
         related_class])
      joins(join_str).group("#{related_table_name}.id")
        .order(Arel.sql("MAX(COALESCE(sources.cached_nomenclature_date, Date('1-1-0001'))) DESC"))
    }

    # SEE https://github.com/rails/arel/issues/399 for issue with ordering by named function
    #define_singleton_method "order_by_youngest_source_first" do
    #  d =  Arel::Attribute.new(Arel::Table.new(:sources), :cached_nomenclature_date)
    #  r  = Arel::Attribute.new(Arel::Table.new(related_table_name), :id)
    #  f1 = Arel::Nodes::NamedFunction.new('Now', [] )
    #  func = Arel::Nodes::NamedFunction.new('COALESCE', [d, f1])

    #  # Fails with bind error, maybe real bug
    #  #  inner_joins = joins(:citations,  :sources).arel.join_sources
    #  #  left_joins = inner_joins.map do |join|
    #  #    Arel::Nodes::OuterJoin.new(join.left, join.right)
    #  #  end

    #  joins("LEFT OUTER JOIN citations on #{related_table_name}.id = citations.citation_object_id
    # LEFT OUTER JOIN sources ON citations.source_id = sources.id").
    #    where("citations.citation_object_type = '#{related_class}'").
    #    group(r).
    #    order(func.desc)
    # end

    define_singleton_method 'order_by_oldest_source_first' do
      d  = Arel::Attribute.new(Arel::Table.new(:sources), :cached_nomenclature_date)
      r  = Arel::Attribute.new(Arel::Table.new(related_table_name), :id)
      f1 = Arel::Nodes::NamedFunction.new('Now', [])

      func  = Arel::Nodes::NamedFunction.new('COALESCE', [d, f1])
      func2 = Arel::Nodes::NamedFunction.new('min', [func])

      # Fails with bind error, maybe real bug with AREL, PSQL
      #  inner_joins = joins(:citations,  :sources).arel.join_sources
      #  left_joins = inner_joins.map do |join|
      #    Arel::Nodes::OuterJoin.new(join.left, join.right)
      #  end

      # was
      #      joins("LEFT OUTER JOIN citations ON #{related_table_name}.id = citations.citation_object_id LEFT OUTER
      # JOIN sources ON citations.source_id = sources.id").
      #      where("citations.citation_object_type = '#{related_class}' OR citations.citation_object_type is null").
      join_str = ActiveRecord::Base.send(
        :sanitize_sql_array,
        ["LEFT OUTER JOIN citations ON #{related_table_name}.id = " \
         'citations.citation_object_id ' \
         'AND citations.citation_object_type = ? LEFT OUTER JOIN sources ' \
         'ON citations.source_id = sources.id',
         related_class])
      joins(join_str).group(r).order(func2)
    end

    accepts_nested_attributes_for :citations, reject_if: :reject_citations, allow_destroy: true
    accepts_nested_attributes_for :origin_citation, reject_if: :reject_citations, allow_destroy: true

    validate :origin_citation_source_id, if: -> {!new_record?}

    # Required to drigger validat callbacks, which in turn set user_id related housekeeping
    validates_associated :citations
  end

  class_methods do
    def oldest_by_citation
      order_by_oldest_source_first.to_a.first
    end

    def youngest_by_citation
      order_by_youngest_source_first.to_a.first
    end
  end

  # See Source::Bibtex for context
  # !! Over-riden in various places.
  # @return [Time, nil]
  def nomenclature_date
    if source && source.is_bibtex?
      source.nomenclature_date
    end
  end

  def origin_citation_source_id
    if origin_citation && origin_citation.source_id.blank?
      errors.add(:base, 'the origin citation must have a source')
    end
  end

  def sources_by_topic_id(topic_id)
    Source.joins(:citation_topics).where(citations: {citation_object: self}, citation_topics: {topic_id: topic_id}) 
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
