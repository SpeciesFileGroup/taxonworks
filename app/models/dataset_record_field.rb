class DatasetRecordField < ApplicationRecord
  include Shared::IsData

  belongs_to :dataset_record

  has_one :import_dataset # To speed up queries, normally should be get from dataset_record
  has_one :project # Security purposes only (avoid leaks)

  VALUE_INDEX_LIMIT = 1000

  def dataset_record_type
    DatasetRecordField.decode_record_type(self.encoded_dataset_record_type)
  end

  def dataset_record_type=(type)
    self.encoded_dataset_record_type = DatasetRecordField.encode_record_type(type)
  end

  def self.at(position)
    where(position: position)
  end

  def self.with_value(value)
    where(indexed_column_value(value).eq(value))
  end

  def self.with_prefix_value(prefix)
    where(indexed_column_value(prefix).matches("#{sanitize_sql_like(prefix)}%"))
  end

  def self.with_record_class(record_class)
    where(
      encoded_dataset_record_type: DatasetRecordField.encode_record_type(record_class)
    )
  end

  class << self
    def indexed_column_value(value)
      unless value.nil? || value.length > VALUE_INDEX_LIMIT # TODO: Is there a way to still use this with NULL value?
        Arel::Nodes::NamedFunction.new("substr", [arel_table[:value], 1, VALUE_INDEX_LIMIT])
      else
        arel_table[:value]
      end
    end

    def encode_record_type(type)
      ENCODED_TYPES_LUT.fetch(type.name)
    end

    def decode_record_type(encoded_type)
      ENCODED_TYPES_LUT.fetch(encoded_type)
    end

    private

    # Unfortunately DatasetRecord.descendants is empty on ActiveJob context, so have to list classes explicitly
    DATASET_RECORD_DESCENDANTS = [
      DatasetRecord::DarwinCore::Extension,
      DatasetRecord::DarwinCore::Occurrence,
      DatasetRecord::DarwinCore::Taxon
    ]

    ENCODED_TYPES_LUT = DatasetRecord.descendants.map(&:name).inject({}) do |lut, type|
      digest = Digest::MD5.hexdigest(type).last(32/4).to_i(16) & (2**31 - 1)
      lut.merge({type => digest, digest => type})
    end

    if ENCODED_TYPES_LUT.values.uniq.length < ENCODED_TYPES_LUT.values.length
      raise "FATAL: Some DatasetRecord types have same digest encoding."
    end
  end
end
