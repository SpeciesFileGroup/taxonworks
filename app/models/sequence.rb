require_dependency 'sequence_relationship'

# A DNA, RNA, or Amino Acid, as defined by a string of letters.
# All other attributes are stored in related tables, the overal model is basically a graph with nodes having attributes.
#
# @!attribute sequence
#   @return [String]
#     the letters representing the sequence
#
# @!attribute sequence_type
#   @return [String]
#     one of "DNA", "RNA", "AA"
#
# @!attribute name
#   @return [String]
#     the _asserted_ name for this sequence, typically the target gene name like "CO1".
#     Important! The preferred mechanism for assinging this type of label to a sequence is
#     assigning pertinent metadata (relationships to other sequences) and then
#     inferrning that those sequences with particular metadata have a
#     specific gene name (Descriptor::Gene#name).
#
class Sequence < ApplicationRecord

  include Housekeeping

  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Confidences
  include Shared::Documentation
  include Shared::Identifiers
  include Shared::Notes
  include Shared::OriginRelationship
  include Shared::ProtocolRelationships
  include Shared::Tags
  include Shared::HasPapertrail
  include Shared::IsData

  is_origin_for 'Sequence'
  originates_from 'Extract', 'Specimen', 'Lot', 'RangedLot', 'Sequence'

  ALTERNATE_VALUES_FOR = [:name].freeze

  # Pass a Gene::Descriptor instance to clone that description to this sequence
  attr_accessor :describe_with

  has_many :sequence_relationships, foreign_key: :subject_sequence_id, inverse_of: :subject_sequence # this sequence describes others
  has_many :sequences, through: :sequence_relationships, source: :object_sequence

  has_many :related_sequence_relationships, class_name: 'SequenceRelationship', foreign_key: :object_sequence_id, inverse_of: :object_sequence # attributes of this sequence
  has_many :related_sequences, through: :related_sequence_relationships, source: :subject_sequence
  has_many :gene_attributes, inverse_of: :sequence

  # has_many :descriptors, through: :gene_attributes, inverse_of: :sequences, as: 'Descriptor::Gene'

  before_validation :build_relationships, if: -> {describe_with.present?}
  before_validation :normalize_sequence_type

  SequenceRelationship.descendants.each do |d|
    t = d.name.demodulize.tableize.singularize
    relationships = "#{t}_relationships".to_sym
    sequences = "#{t}_sequences".to_sym

    has_many relationships, class_name: d.name.to_s, foreign_key: :object_sequence_id, inverse_of: :object_sequence
    has_many sequences, class_name: 'Sequence', through: relationships, source: :subject_sequence, inverse_of: :sequences

    accepts_nested_attributes_for sequences
    accepts_nested_attributes_for relationships
  end

  validates_presence_of :sequence
  validates_inclusion_of :sequence_type, in: ['DNA', 'RNA', 'AA']

  # @return [Array]
  #   all SequenceRElationships where this sequences is an object or subject.
  def all_sequence_relationships
    SequenceRelationship.find_by_sql(
      "SELECT sequence_relationships.*
         FROM sequence_relationships
         WHERE sequence_relationships.subject_sequence_id = #{self.id}
       UNION
       SELECT sequence_relationships.*
         FROM sequence_relationships
         WHERE sequence_relationships.object_sequence_id = #{self.id}")
  end

  # @param used_on [String] required, one of `GeneAttribute` or `SequenceRelationship`
  # @return [Scope]
  #   the max 10 most recently used otus, as `used_on`
  def self.used_recently(user_id, project_id, used_on = nil)
    return Sequence.none if used_on.nil?
    case used_on
    when 'GeneAttribute'
       Sequence.joins(:gene_attributes)
         .where(
           gene_attributes: {
             updated_by_id: user_id,
             project_id:,
             updated_at: 1.week.ago..}
         )
    when 'SequenceRelationship'
      a = Sequence.joins(:sequence_relationships)
        .where(
          sequence_relationships: {
            updated_by_id: user_id,
            project_id:,
            updated_at: 1.week.ago..}
        )
      b = Sequence.joins(:related_sequence_relationships)
        .where(
          sequence_relationships: {
            updated_by_id: user_id,
            project_id:,
            updated_at: 1.week.ago..}
        )

      ::Queries.union(Sequence, [a,b])
    else
      return []
    end
  end

  # @params target [String] one of nil, 'SequenceRelationship', 'GeneAttribute'
  # @return [Hash] otus optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)

    new_sequences = Sequence.where(
          created_by_id: user_id,
          updated_at: 2.hours.ago..Time.now )
          .order('created_at DESC')
          .limit(5)
    recent_sequences = Sequence.where(id: r.first(10) )

    pinboard_sequences = Sequence.pinned_by(user_id).where(project_id: project_id)

    h = {
      quick: [],
      recent: [],
      pinboard: pinboard_sequences.to_a
    }

    if r.empty?
      h[:quick] = (pinboard_sequences.to_a + recent_sequences.first(5).to_a).uniq
      h[:recent] = new_sequences.to_a
    else
      h[:recent] = (new_sequences.to_a + recent_sequences.to_a).uniq
      h[:quick] = (pinboard_sequences.to_a + recent_sequences.to_a).uniq
    end

    h
  end

  protected

  def build_relationships
    describe_with.gene_attributes.each do |ga|
      related_sequence_relationships.build(subject_sequence: ga.sequence, type: ga.sequence_relationship_type)
    end
  end

  def normalize_sequence_type
    sequence_type.to_s.upcase! if sequence_type.present?
  end

end


