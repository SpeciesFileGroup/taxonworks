# A Descriptor::Gene defines a set of sequences, i.e. column in a "matrix" whose
# cells contains sequences that match the a set of GeneAttributes. 
#
# The column (conceptually set of sequences) is populated by things that match (all) of the GeneAttibutes attached to the Descriptor::Gene.
# 

# require "logic_tools/logictree.rb"
# require "logic_tools/logicparse.rb"
# require "logic_tools/logicsimplify_es.rb"
# include LogicTools

class Descriptor::Gene < Descriptor

  has_many :gene_attributes, inverse_of: :descriptor, foreign_key: :descriptor_id
  accepts_nested_attributes_for :gene_attributes

  # Pass a Sequence to clone that sequence description to this descriptor
  attr_accessor :base_on_sequence

  before_validation :add_gene_attributes, if: -> { base_on_sequence.present? } 
  before_validation :cache_gene_attribute_logic_sql, if: :gene_attribute_logic_changed? 

  after_save :validate_gene_attribute_logic

  # @return [Scope]
  #   a Sequence scope that returns sequences for this Descriptor::Gene
  #   
  #   Only those Sequences that exactly match all, and only those
  #   gene attributes are returned
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
  # TODO: move to exact_and
  def sequences
    return Sequence.none if !gene_attributes.all.any?

    data = gene_attribute_pairs

    s = Sequence.arel_table
    sr = SequenceRelationship.arel_table

    j = s.alias('j') # required for group/having purposes

    b = s.project(j[Arel.star]).from(j)
      .join(sr)
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

  def or_sequences
    return Sequence.none if !gene_attributes.all.any?

#    s = Sequence.arel_table
    sr = SequenceRelationship.arel_table

    clauses = gene_attribute_pairs.collect{ |subject_sequence_id, type|
      sr[:subject_sequence_id].eq(subject_sequence_id)
        .and(sr[:type].eq(type))
    } 

    q = clauses.shift 
    clauses.each do |c|
      q = q.or(c)
    end

    Sequence.joins(:related_sequence_relationships).where(q.to_sql).references(:sequence_relationships).distinct
  end

  def ga_sequences
    return Sequence.none if !gene_attributes.all.any?

    Sequence.joins(:related_sequence_relationships).where(cached_gene_attribute_sql).references(:sequence_relationships).where(sequence_relationships: {object_sequence_id: id}).distinct
  end

  # @return [Array]
  #   of arrays, like [[id, type], [id, type]]
  def gene_attribute_pairs
    gene_attributes.all.pluck(:sequence_id, :sequence_relationship_type)
  end

  def gene_attribute_sequence_ids
    gene_attribute_pairs.collect{|id, z| id}
  end

  def gene_attribute_sequence_relationship_types
    gene_attribute_pairs.collect{|id, z| z}
  end

  def build_gene_attribute_logic_sql(str = nil)
    return nil if str.nil?
    parser = LogicalQueryParser.new
    parser.parse(str).to_sequence_relationship_sql 
  end

  def extend_gene_attribute_logic(gene_attribute, logic = :and)
    logic.downcase!.to_sym! unless logic.kind_of?(Symbol)
    raise if ![:and,:or].include?(logic)

    append_gene_attribute_logic(gene_attribute, logic)
    cache_gene_attribute_logic_sql
  end

  # @return [Boolean]
  #     true if the current logic statement contains the attribute in question
  def contains_logic_for?(gene_attribute)
    gene_attribute_logic =~ /#{gene_attribute.to_logic_literal}/  ? true : false
  end

  protected

  def add_gene_attributes
    base_on_sequence.related_sequence_relationships.each do |sa|
      gene_attributes.build(sequence: sa.sequence, type: sa.type)
    end
  end

  def validate_gene_attribute_logic
    gene_attributes.each do |ga|
      error.add(:base, 'gene_attribute not referenced in gene attribute logic') unless contains_logic_for?(ga)
    end
  end

  def append_gene_attribute_logic(gene_attribute, logic = :and)
    v = [gene_attribute_logic, gene_attribute.to_logic_literal].compact.join(' AND ')
    update_column(:gene_attribute_logic, v)
  end

  def cache_gene_attribute_logic_sql
    write_attribute(:cached_gene_attribute_sql, build_gene_attribute_logic_sql(gene_attribute_logic))
  end



end
