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
  originates_from 'Extract', 'Specimen', 'Lot', 'RangedLot'

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

  # @param used_on [String] required, one of `GeneAttribute` or `SequenceRelationship`
  # @return [Scope]
  #   the max 10 most recently used otus, as `used_on`
  def self.used_recently(user_id, project_id, used_on = '')
    t = case used_on
        when 'GeneAttribute'
          GeneAttribute.arel_table
        when 'SequenceRelationship'
          SequenceRelationship.arel_table
        end

    p = Sequence.arel_table

    # i is a select manager
    i = t.project(t['sequence_id'], t['updated_at']).from(t)
      .where(t['updated_at'].gt( 1.weeks.ago ))
      .where(t['created_by_id'].eq(user_id))
      .where(t['project_id'].eq(project_id))
      .order(t['updated_at'].desc)

    # i is a select manager
    i = case used_on 
        when 'SequenceRelationship'
          t.project(t['object_sequence_id'], t['updated_at']).from(t)
            .where(
              t['updated_at'].gt(1.weeks.ago)
          )
              .where(t['created_by_id'].eq(user_id))
              .where(t['project_id'].eq(project_id))
            .order(t['updated_at'])
        else
          t.project(t['sequence_id'], t['updated_at']).from(t)
            .where(t['updated_at'].gt( 1.weeks.ago ))
              .where(t['created_by_id'].eq(user_id))
              .where(t['project_id'].eq(project_id))
            .order(t['updated_at'])
        end

    # z is a table alias
    z = i.as('recent_t')

    j = case used_on
        when 'SequenceRelationship' 
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
            z['object_sequence_id'].eq(p['id'])
          ))
        else
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['sequence_id'].eq(p['id'])))
        end

    Sequence.joins(j).pluck(:sequence_id).uniq
  end

  # @params target [String] one of nil, 'SequenceRelationship', 'GeneAttribute'
  # @return [Hash] otus optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)
    h = {
      recent: [],
      quick: [],
      pinboard: Sequence.pinned_by(user_id).where(project_id: project_id).to_a
    }

    if r.empty?
      h[:quick] = Sequence.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Sequence.where('"sequences"."id" IN (?)', r.first(10) ).to_a
      h[:quick] = (Sequence.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
          Sequence.where('"sequences"."id" IN (?)', r.first(10) ).to_a).uniq
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


