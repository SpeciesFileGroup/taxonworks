# A DatasetRecord is the unit of data (typically a table row) from an ImportDataset
#
# @!attribute metadata
#   @return [Hash]
#      data about the record. No particular structure is enforced, any subclass may store metadata (typically to aid the import process).
#
# @!attribute status
#   @return [String]
#    current import status (e.g. Pending, Imported, Deleted, etc.)
#
class DatasetRecord < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  belongs_to :import_dataset

  has_many :dataset_record_fields, -> { order(position: :asc) }, autosave: true # dependent: :destroy too expensive when deleting multiple dataset records.

  validates :type, presence: true
  validates :status, presence: true

  scope :preload_fields, -> { includes(:dataset_record_fields) }

  def initialize_data_fields(field_data)
    field_data.each_with_index do |value, position|
      dataset_record_fields.build(
        value: value,
        position: position,
        frozen_value: false,
        encoded_dataset_record_type: DatasetRecordField.encode_record_type(self.class),
        import_dataset: import_dataset,
        project: import_dataset.project
      )
    end
  end

  def data_fields
    dataset_record_fields
  end

  def set_data_field(index, value)
    field = dataset_record_fields[index]

    unless field.frozen_value
      field.value = value
      data_field_changed(index, value)
    end
  end

  def freeze_data_field(index)
    dataset_record_fields[index].frozen_value = true
  end

  def freeze_all_data_fields
    dataset_record_fields.each { |f| f.frozen_value = true }
  end

  def freeze_persisted_data_fields
    dataset_record_fields.update_all(frozen_value: true)
  end

  private

  def data_field_changed(index, value)
    # Subclasses may re-implement to perform actions when field change
  end
end
