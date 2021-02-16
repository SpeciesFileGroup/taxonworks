# A Descriptor::Gene defines a set of sequences, i.e. column in a "matrix" whose
# cells contain Sequences with a specific set of attributes (e.g. forward and reverse primers), as defined by GeneAttributes.
#
# A user may define the set of sequences returned by the descriptor via a logical expression.  For example
# show me all sequences with this set of forward primers and that set of reverse primers.  The logic
# can be expanded as extensively as needed, up to a maximum 52 attributes.
#
# @!attribute gene_attribute_logic
#   @return [String]
#     A logical expression describing how the gene attributes (e.g. primers) should be intepretted when
#     return sequences. Call @gene_attribute.to_logic_literal for the format of individual gene attribute references.
#     Use parenthesis, ` AND ` and ` OR ` to compose the statements.
#     For example:
#        (SequenceRelationship::ForwardPrimer.2 OR SequenceRelationship::ForwardPrimer.3) AND SequenceRelationship::ReversePrimer.4
#
#  @!attribute cached_gene_attribute_sql
#   @return [String]
#     An automatically composed SQL fragment that corresponds to #gene_attribute_logic.  Used in #sequences.
#
class Descriptor::Gene < Descriptor

  has_many :gene_attributes, inverse_of: :descriptor, foreign_key: :descriptor_id

  # A Sequence, if provided clone that sequence description to this Descriptor::Gene
  attr_accessor :base_on_sequence

  before_validation :add_gene_attributes, if: -> {base_on_sequence.present?}

  validate :gene_attribute_logic_compresses, if: :gene_attribute_logic_changed?
 
  validate :gene_attribute_logic_parses, if: -> {
    gene_attribute_logic_changed? && !errors.any?
  }
  
  validate :gene_attribute_logic_matches_gene_attributes, if: :gene_attribute_logic_changed?

  # TODO: use common cache/set_cache pattern
  after_save :cache_gene_attribute_logic_sql, if: -> {
    saved_change_to_gene_attribute_logic? && valid?
  }

  accepts_nested_attributes_for :gene_attributes, allow_destroy: true

  # @return [Scope]
  #   Sequences using AND for the supplied target attributes
  #
  # @param :target_attributes
  #    [[], [] ...] an array as generated from #sequence_query_set
  def self.sequences_for_gene_attributes(object_sequence_id = nil, target_attributes = [], table_alias = nil)
    return Sequence.none if target_attributes.empty?

    s  = Sequence.arel_table
    sr = SequenceRelationship.arel_table

    a = s.alias("a_#{table_alias}")

    b = s.project(a[Arel.star]).from(a)
          .join(sr)
          .on(sr['object_sequence_id'].eq(a['id']))

    i = 0
    target_attributes.each do |sequence_type, id|
      sr_a = sr.alias("#{table_alias}_#{i}")
      b = b.join(sr_a).on(
        sr_a['object_sequence_id'].eq(a['id']),
        sr_a['type'].eq(sequence_type),
        sr_a['subject_sequence_id'].eq(id)
      )
      i += 1
    end

    b = b.group(a['id']).having(sr['object_sequence_id'].count.gteq(target_attributes.count))
    b = b.as("z_#{table_alias}")

    Sequence.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(s['id']))))
  end

  # @return [Array]
  #   of Arrays, like [[sequence_id, sequence_relationship_type], [sequence_id, sequence_relationship_type]]
  def self.gene_attribute_pairs(target_gene_attributes = GeneAttribute.none)
    target_gene_attributes.pluck(:sequence_id, :sequence_relationship_type)
  end

  # @return [Scope]
  #   Sequences as determined by #gene_attribute_logic, or
  #   if that is nil, #sequences_matching_any_gene_attributes
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

    s  = Sequence.arel_table
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

    # match only those sequences with exactly these attributes, no more, no less
    b = b.group(j['id']).having(sr['object_sequence_id'].count.eq(data.count))

    b = b.as('join_alias')

    Sequence.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(s['id']))))
  end

  # @return [Scope]
  #   Sequences matching any #gene_attributes
  #   !! This ignores logic in gene_attribute_logic !!
  def sequences_matching_any_gene_attributes
    return Sequence.none if !gene_attributes.all.any?

    sr = SequenceRelationship.arel_table

    clauses = gene_attribute_pairs.collect {|subject_sequence_id, type|
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
  #   of Arrays, like [[sequence_id, sequence_relationship_type], [sequence_id, sequence_relationship_type]]
  def gene_attribute_pairs
    Descriptor::Gene.gene_attribute_pairs(gene_attributes.all)
  end

  # @return [Boolean]
  #   true if the current logic statement contains the gene_attribute
  def contains_logic_for?(gene_attribute)
    gene_attribute_logic =~ /#{gene_attribute.to_logic_literal}/ ? true : false
  end

  # @return [Array]
  def sequence_query_set
    attributes_from_or_queries(
      Utilities::Logic.or_queries(compress_logic)
    )
  end

  # @return [Array]
  def attributes_from_or_queries(queries)
    translate = gene_attribute_term_index.invert
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

  # @return [Hash]
  #   a lookup linking key/value terms to their single letter representation
  #   note that
  def gene_attribute_term_index
    h = {}
    return h if gene_attribute_logic.blank?

    symbols = ('a'..'z').to_a + ('A'..'Z').to_a
    matches = gene_attribute_logic.scan(/([A-Za-z:]+\.[\d]+)/).flatten
  
    matches.each_with_index do |m, i|
      h[m] = symbols[i]
    end
    h
  end

  # @return [String]
  #   translates each key/value (SequenceRelationshipType.SequenceID) term into a single letter term
  #   and translates 'AND' to '+' and 'OR' to '.'
  def compress_logic
    return '' if gene_attribute_logic.blank?

    a = gene_attribute_logic.dup
    b = gene_attribute_term_index

    b.each do |k, v|
      # Match whole words, ABC should only match ABC NOT AB.
      # Uses lookahead to acomplish this by checking if the
      # next character is a space, closing parentheses, or
      # is the end of the string
      a.gsub!(/#{k}(?=[\s)]|$)/, v)
    end
    a.gsub!(/\s+OR\s+/, '+')
    a.gsub!(/\s+AND\s+/, '.')
    a.gsub!(/\s+/, '')
    a
  end

  # See use in GeneAttribute
  def extend_gene_attribute_logic(gene_attribute, logic = :and)
    logic.downcase!.to_sym! unless logic.kind_of?(Symbol)
    raise if ![:and, :or].include?(logic)

    append_gene_attribute_logic(gene_attribute, logic)
    cache_gene_attribute_logic_sql
  end

  protected

  def gene_attribute_logic_compresses
    if compress_logic.match?(/[^a-zA-Z\(\)\.\+]/)
      errors.add(:gene_attribute_logic, 'is invalidly formed (likely a bad sequence_relationship_type)')
    end
  end

  def gene_attribute_logic_parses
    begin
      Utilities::Logic.parse_logic(compress_logic).to_s.split('+')
    rescue Parslet::ParseFailed => e
      errors.add(:gene_attribute_logic, "is invalidly formed: #{e}")
    end
  end

  def gene_attribute_logic_matches_gene_attributes
    a = gene_attribute_term_index.keys
    b = gene_attributes.select{|ga| !ga.marked_for_destruction? }.collect{|l| l.to_logic_literal}
    c = a - b
    d = b - a

    errors.add(:gene_attribute_logic, "provided logic without matching gene attribute: #{c.join(';')}") if !c.empty?
    errors.add(:gene_attribute_logic, "gene attribute (#{d.join(';')}) not referenced in provided logic") if !d.empty?
    !errors.any?
  end

  def add_gene_attributes
    base_on_sequence.related_sequence_relationships.each do |sa|
      gene_attributes.build(sequence: sa.sequence, type: sa.type)
    end
  end

  def append_gene_attribute_logic(gene_attribute, logic = :and)
    v = [gene_attribute_logic, gene_attribute.to_logic_literal].compact.join(' AND ')
    update_column(:gene_attribute_logic, v)
  end

  def build_gene_attribute_logic_sql
    queries = []
    sequence_query_set.each_with_index do |target_attributes, i|
      queries.push Descriptor::Gene.sequences_for_gene_attributes(id, target_attributes, "uq#{i}")
    end

    queries.collect{|q| "(#{q.to_sql})"}.join(' UNION ')
  end

  def cache_gene_attribute_logic_sql
    update_column(:cached_gene_attribute_sql, build_gene_attribute_logic_sql)
  end

end
