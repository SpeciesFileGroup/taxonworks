# Helpers for queries that reference AlternateValue
#
# !!  Classes including this must be subclasses of Queries::Query !!
#
module Queries::Concerns::AlternateValues

  extend ActiveSupport::Concern

  included do
    # @return [Array]
    #   alternatve_value_type[] =
    attr_accessor :alternate_value_type
  end

  def set_alternate_value(params)
    @alternate_value_type = params[:alternate_value_type] || ALTERNATE_VALUE_CLASS_NAMES
  end

  def matching_alternate_value_on(attribute = nil)
    return nil if attribute.nil?  # empty? keyword_ids.empty?
    k = table.name.classify.safe_constantize
    t = ::AlternateValue.arel_table

    k.joins(:alternate_values).where(
      t[:value].matches_any(terms) # terms is from Queries::Query
      .and( t[:alternate_value_object_attribute].eq(attribute)) # terms is from Queries::Query
      .and(t[:type].eq_any(alternate_value_type))
      .to_sql
    )
  end

  # TODO: not used, but potentially useful
  def matching_alternate_value_on_values(attribute = nil, values = [])
    return nil if attribute.nil? || values.compact.empty?
    k = table.name.classify.safe_constantize
    t = ::AlternateValue.arel_table

    k.joins(:alternate_values).where(
      t[:value].matches_any(values) # terms is from Queries::Query
      .and( t[:alternate_value_object_attribute].eq(attribute)) # terms is from Queries::Query
      .and(t[:type].eq_any(alternate_value_type))
      .to_sql
    )
  end


end
