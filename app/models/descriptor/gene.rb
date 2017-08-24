# A Descriptor::Gene defines a set of sequences, i.e. column in a "matrix" whose
# cells contains sequences that match the a set of GeneAttributes. 
#
# The column (conceptually set of sequences) is populated by things that match (all) of the GeneAttibutes attached to the Descriptor::Gene.
# 
# @!attribute gene_attribute_logic 
#   @return [String]
#     A logical expression describing how the gene attributes (e.g. primers) should be intepretted when
#     return sequences. Call @gene_attribute.to_logic_literal for the format of individual gene attribute references.
#     Use parenthesis, ` AND ` and ` OR ` to compose the statements.
#     For example:
#
#     ( SequenceRelationship::ForwardPrimer.2 OR SequenceRelationship::ForwardPrimer.3) AND SequenceRelationship::ReversePrimer.4
#
#  @!attribute cached_gene_attribute_sql
#   @return [String]
#     A automatically compose SQL fragment that corresponds to #gene_attribute_logic.  Used in #sequences.
#
class Descriptor::Gene < Descriptor

  has_many :gene_attributes, inverse_of: :descriptor, foreign_key: :descriptor_id
  accepts_nested_attributes_for :gene_attributes

  # Pass a Sequence to clone that sequence description to this Descriptor::Gene 
  attr_accessor :base_on_sequence

  before_validation :add_gene_attributes, if: -> { base_on_sequence.present? } 
  before_validation :cache_gene_attribute_logic_sql, if: :gene_attribute_logic_changed? 

  after_save :validate_gene_attribute_logic

  # @return [Scope]
  #    Sequences as determined by #gene_attribute_logic, or
  #    if that is nil, #sequences_matching_any_gene_attributes
  def sequences
    return Sequence.none if !gene_attributes.all.any?
    return sequences_matching_any_gene_attributes if gene_attribute_logic.blank?
    Sequence.from("(#{cached_gene_attribute_sql}) as sequences").distinct      
  end

  # @return [Scope]
  #   a Sequence scope that matches ALL, and only ALL gene attributes
  #   AHA from http://stackoverflow.com/questions/28568205/rails-4-arel-join-on-subquery
  def strict_and_sequences
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

    Sequence.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(s['id']))))
  end

  # @return [Scope]
  #   Sequence matching any gene attribute assigned to this descriptor
  #   !! ignores logic in gene_attribute_logic !! 
  def sequences_matching_any_gene_attributes
    return Sequence.none if !gene_attributes.all.any?

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

  # @return [Array]
  #   of arrays, like [[sequence_id, sequence_relationship_type], [sequence_id, sequence_relationship_type]]
  def gene_attribute_pairs
    Descriptor::Gene.gene_attribute_pairs(gene_attributes.all)
  end

  # @return [Array]
  #   of arrays, like [[sequence_id, sequence_relationship_type], [sequence_id, sequence_relationship_type]]
  def self.gene_attribute_pairs(target_gene_attributes = GeneAttribute.none)
    target_gene_attributes.pluck(:sequence_id, :sequence_relationship_type)
  end

  def gene_attribute_sequence_ids
    gene_attribute_pairs.collect{|id, z| id}
  end

  def gene_attribute_sequence_relationship_types
    gene_attribute_pairs.collect{|id, z| z}
  end

  def build_gene_attribute_logic_sql
    queries = []
    sequence_query_set.each_with_index do |target_attributes, i|
      queries.push Descriptor::Gene.sequences_for_gene_attributes(id, target_attributes, "union_qry#{i}")
    end

    queries.collect{|q| "(#{q.to_sql})"}.join(' UNION ')
  end

  def extend_gene_attribute_logic(gene_attribute, logic = :and)
    logic.downcase!.to_sym! unless logic.kind_of?(Symbol)
    raise if ![:and,:or].include?(logic)

    append_gene_attribute_logic(gene_attribute, logic)
    cache_gene_attribute_logic_sql
  end

  # @return [Boolean]
  #   true if the current logic statement contains the attribute in question
  def contains_logic_for?(gene_attribute)
    gene_attribute_logic =~ /#{gene_attribute.to_logic_literal}/  ? true : false
  end



  # @return [Scope]
  #   Sequences using AND for the supplied target attributes
  # @param :target_attributes
  #    [[], [] ...] an array as generated from #sequence_query_set
  def self.sequences_for_gene_attributes(object_sequence_id = nil, target_attributes = [], table_alias = nil)
    return Sequence.none if target_attributes.empty? 

    s = Sequence.arel_table
    sr = SequenceRelationship.arel_table

    j = s.alias("o_#{table_alias}") 

    b = s.project(j[Arel.star]).from(j)
      .join(sr)
      .on(sr['object_sequence_id'].eq(j['id']))

    i = 0
    target_attributes.each do |sequence_type, id|
      sr_a = sr.alias("#{table_alias}_#{i}_o")
      b = b.join(sr_a).on(
        sr_a['object_sequence_id'].eq(j['id']),
        sr_a['type'].eq(sequence_type), 
        sr_a['subject_sequence_id'].eq(id)
      )
      i+=1
    end

    b = b.group(j['id']).having(sr['object_sequence_id'].count.gteq(target_attributes.count))
    b = b.as("z_#{table_alias}") 

    Sequence.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(s['id']))))
  end

  def or_queries(expression)
    Utilities::Logic.parse_logic(expression).to_s.split('+')
  end

  def sequence_query_set
    c = or_queries(compress_logic)
    attributes_from_or_queries(c) 
  end

  def attributes_from_or_queries(queries)
    translate = axiomize_gene_attribute_logic.invert
    a = []
    queries.each do |v|
      b = []
      v.split(//).each do |axiom|
        b.push translate[axiom].split(/\./) 
      end
      a.push b
    end
    a
  end

  def axiomize_gene_attribute_logic 
    symbols = ("a".."z").to_a + ("A".."Z").to_a
    matches = gene_attribute_logic.scan(/([A-Za-z:]+\.[\d]+)/).flatten
    h = {}
    matches.each_with_index do |m, i|
      h[m] = symbols[i]
    end
    h
  end

  def compress_logic
    a = gene_attribute_logic.dup
    b = axiomize_gene_attribute_logic

    b.each do |k,v|
      a.gsub!(/#{k}/, v) 
    end
    a.gsub!(/\s+OR\s+/, '+')
    a.gsub!(/\s+AND\s+/, '.')
    a
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
    write_attribute(:cached_gene_attribute_sql, build_gene_attribute_logic_sql)
  end



end
