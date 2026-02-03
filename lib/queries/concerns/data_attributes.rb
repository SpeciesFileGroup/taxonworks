# Linking DataAttribute to  queries that reference DataAttributes
#
# For filter queries:
# !! requires `set_data_attributes_params` be called in initialize()
#
module Queries::Concerns::DataAttributes
  include Queries::Helpers

  def self.params
    [
      :data_attribute_combine_logic,
      :data_attribute_predicate_id,
      :data_attribute_value,
      :data_attribute_value_negator,
      :data_attribute_value_type,

      data_attribute_combine_logic: [],
      data_attribute_predicate_id: [],
      data_attribute_value: [],
      data_attribute_value_negator: [],
      data_attribute_value_type: [],
    ]
  end

  extend ActiveSupport::Concern

  included do
    # Params are received in columns, but combined in rows. In other words,
    # query1 becomes
    #   "[pred_id[0]] IS [value_negator[0]][value_type[0]] [value[0]]"
    #       Color     IS      '(not)'         EXACTLY        'green'
    #
    # query1 and query2 are combined according to [combine_logic[0]]
    # Etc.

    # @param data_attribute_combine_logic
    # @return Array[Boolean]
    #   How to combine the results of the queries in this row and the next:
    #     nil - AND
    #     true - OR
    #     false - AND NOT
    # !! Precedence is simply top to bottom:
    #   r1 OR r2 AND r3 is ((r1 OR r2) AND r3), not SQL's (r1 OR (r2 AND r3))
    # !! Note that AND NOT is global, i.e. AND NOT p.value = 'asdf' returns the
    #   world except for objects with p.value = 'asdf'
    attr_accessor :data_attribute_combine_logic

    # @param data_attribute_predicate_id
    # @return Array[0 or positive integers]
    #   Predicate id or 0 to meany 'any predicate'
    attr_accessor :data_attribute_predicate_id

    # @param data_attribute_value
    # @return Array[String]
    #   Values of data attributes.
    attr_accessor :data_attribute_value

    # @param data_attribute_value_negator
    # @return Array[Boolean]
    #   True to negate the value_type in this row
    #   False or nil - ignore
    attr_accessor :data_attribute_value_negator

    # @param data_attribute_value_type
    # @return Array[String]
    #   One of:
    #     * exact - match data attribute value exactly
    #     * wildcard - match data attribute value by %value%
    #     * any - match any value on the given data attribute
    #     * no - match only if the given attribute has no value
    attr_accessor :data_attribute_value_type


    def data_attribute_combine_logic
      [@data_attribute_combine_logic].flatten
    end

    def data_attribute_predicate_id
      [@data_attribute_predicate_id].flatten.compact
    end

    def data_attribute_value
      [@data_attribute_value].flatten.compact
    end

    def data_attribute_value_negator
      [@data_attribute_value_negator].flatten
    end

    def data_attribute_value_type
      [@data_attribute_value_type].flatten.compact
    end

    def data_attribute_import_exact_pair
      return {} if @data_attribute_import_exact_pair.blank?
      if @data_attribute_import_exact_pair.kind_of?(Hash)
        @data_attribute_import_exact_pair
      else
        split_pairs([@data_attribute_import_exact_pair].flatten.compact)
      end
    end

    def data_attribute_import_predicate
      [@data_attribute_import_predicate].flatten.compact
    end
  end

  def set_data_attributes_params(params)
    row_count = [params[:data_attribute_predicate_id]].flatten.compact.count
    return if (
      row_count == 0 ||
      [params[:data_attribute_value]].flatten.compact.count != row_count ||
      tri_value_array(params[:data_attribute_value_negator]).length != row_count ||
      [params[:data_attribute_value_type]].flatten.compact.count != row_count ||
      tri_value_array(params[:data_attribute_combine_logic]).length != row_count
    )

    @data_attribute_predicate_id =
      [params[:data_attribute_predicate_id]].flatten.compact
    @data_attribute_value =
      [params[:data_attribute_value]].flatten.compact
    @data_attribute_value_negator =
      tri_value_array(params[:data_attribute_value_negator])
    @data_attribute_value_type =
      [params[:data_attribute_value_type]].flatten.compact
    @data_attribute_combine_logic =
      tri_value_array(params[:data_attribute_combine_logic])
  end

  # @return [Arel::Table]
  def data_attribute_table
    ::DataAttribute.arel_table
  end

  def data_attribute_facet
    return nil if data_attribute_predicate_id.empty?

    queries = []
    data_attribute_value_type.map(&:to_sym).each_with_index do |value_type, i|
      id = data_attribute_predicate_id[i].to_i
      value = data_attribute_value[i]
      negator = data_attribute_value_negator[i]

      q = nil
      case value_type
      when :exact, :wildcard
        value_clause = if value_type == :exact
          data_attribute_table[:value].eq(value)
        else
          data_attribute_table[:value].matches("%#{value}%")
        end

        value_clause = value_clause.not if negator

        if id > 0
          value_clause = value_clause.and(
            data_attribute_table[:controlled_vocabulary_term_id].eq(id)
          )
        end

        q = referenced_klass
          .joins(:internal_attributes)
          .where(value_clause)
          .distinct

      when :any, :no
        has_attr = (value_type == :any && !negator) || (value_type == :no && negator)

        if id == 0 # any predicate
          q = has_attr ?
            referenced_klass.joins(:internal_attributes) :
            referenced_klass.left_joins(:internal_attributes)
              .where(data_attributes: { id: nil })
        else
          with_predicate = referenced_klass
            .joins(:internal_attributes)
            .where(data_attributes: { controlled_vocabulary_term_id: id })
          q = has_attr ? with_predicate : referenced_klass.where.not(id: with_predicate)
        end

        q.distinct
      end

      queries << q
    end

    return nil if queries.empty?

    q = queries.first
    # TODO? We're currently doing simple top to bottom precedence, which I think
    # (?) is what users would expect, and this will probably be fine, but it does # make repeated ANDs and ORs heavier on the sql extras than doing a one-time # intersection, one-time union would be.
    data_attribute_combine_logic.each_with_index do |c, i|
      if c.nil?
        q = referenced_klass_intersection([q, queries[i + 1]])
      elsif c == true
        q = referenced_klass_union([q, queries[i + 1]])
      else
        q = q.where.not(id: queries[i + 1])
      end
    end

    q
  end

  # TODO: this as class method is bad,
  #  it prevents us from adding optimizing logic
  #  that restricts the number of clauses
  def self.merge_clauses
    [
      :data_attribute_facet
    ]
  end

end
