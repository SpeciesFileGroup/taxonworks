# A Descriptor::Gene defines a set of sequeces, i.e. column in a "matrix" whose
# cells contains sequences that match the a set (logical AND) of GeneAttributes. 
#
# The column (conceptually set of sequences) is populated by things that match (all) of the GeneAttibutes attached to the Descriptor::Gene.
# 
class Descriptor::Gene < Descriptor

  has_many :gene_attributes, inverse_of: :descriptor, foreign_key: :descriptor_id
  accepts_nested_attributes_for :gene_attributes

  # Pass a Sequence to clone that sequence description to this descriptor
  attr_accessor :base_on_sequence

  before_validation :add_gene_attributes, if: 'base_on_sequence.present?'

  # @return [Scope]
  #   a Sequence scope that returns sequences for this Descriptor::Gene
  #
  # Arel is use to represent this raw SQL approach:
  #
  #  js = data.collect{|j, k| " INNER JOIN sequence_relationships b#{j} ON s.id = b#{j}.object_sequence_id AND b#{j}.type = '#{k}' AND b#{j}.subject_sequence_id = #{j}"}.join  
  #
  #  z = 'SELECT s.* FROM sequences s' +
  #      ' INNER JOIN sequence_relationships sr ON sr.object_sequence_id = s.id' +
  #      js + 
  #      ' GROUP BY s.id' +
  #      " HAVING COUNT(sr.object_sequence_id) = #{data.count};" 
  #
  def sequences
    return Sequence.none if !gene_attributes.any?

    data = gene_attribute_pairs

    s = Sequence.arel_table
    sr = SequenceRelationship.arel_table

    j = s.alias('j') # required for group/having purposes

    b = s.project(j[Arel.star]).from(j)
      .join(sr )
      .on(sr['object_sequence_id'].eq(j['id']))

    # Build an aliased join for each set of attributes
    data.each do |id, type|
      sr_a = sr.alias("b#{id}")
      b = b.join(sr_a).on(
        sr_a['object_sequence_id'].eq(j['id']),
        sr_a['type'].eq(type), 
        sr_a['subject_sequence_id'].eq(id)
      )
    end

    b = b.group(j['id']).having(sr['object_sequence_id'].count.eq(data.count))
    b = b.as('foo')

    # AHA from http://stackoverflow.com/questions/28568205/rails-4-arel-join-on-subquery
    Sequence.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(s['id']))))
  end

  # @return [Array]
  #   of arrays, like [[id, type], [id, type]]
  def gene_attribute_pairs
     gene_attributes.pluck(:sequence_id, :sequence_relationship_type)
  end

  def gene_attribute_sequence_ids
    gene_attribute_pairs.collect{|id, z| id}
  end

  def gene_attribute_sequence_retlationship_types
    gene_attribute_pairs.collect{|id, z| z}
  end

  protected

  def add_gene_attributes
    base_on_sequence.related_sequence_relationships.each do |sa|
      gene_attributes.build(sequence: sa.sequence, type: sa.type)
    end
  end

end
