# Levenshtein function wrapper.
#
module Shared::IsData::Levenshtein
  extend ActiveSupport::Concern

  # TODO: make this a proper instance method, remove limit from scope

  # @param [String, String, Integer]
  # @return [Scope]
  def nearest_by_levenshtein(compared_string = nil, column = nil, limit = 10)
    return self.class.none if compared_string.nil? || column.nil?
    order_str = self.class.send(:sanitize_sql_for_conditions, ["levenshtein(left(#{self.class.table_name}.#{column}, 255), ?)", compared_string[0..254] ])
    self.class.where('id <> ?', self.to_param).
      select("sources.*, #{order_str}").
      order(Arel.sql(order_str)).
      limit(limit)
  end

end
