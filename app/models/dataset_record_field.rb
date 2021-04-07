class DatasetRecordField < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  belongs_to :import_dataset # To speed up queries, normally should be get from dataset_record
  belongs_to :dataset_record

  VALUE_INDEX_LIMIT = 1000

  def self.at(position)
    where(position: position)
  end

  def self.with_value(value)
    where(indexed_column_value(value).eq(value))
  end

  def self.with_prefix_value(prefix)
    where(indexed_column_value(prefix).matches("#{prefix.gsub(/([%_\[\\])/, '\\\\\1')}%"))
  end

  private

  def self.indexed_column_value(value)
    if value.length <= VALUE_INDEX_LIMIT
      Arel::Nodes::NamedFunction.new("substr", [arel_table[:value], 1, VALUE_INDEX_LIMIT])
    else
      arel_table[:value]
    end
  end
end
