# A DatasetRecord is the unit of data (typically a table row) from an ImportDataset
#
# @!attribute data_fields
#   @return [Array]
#      data of each record field. Structure: [ { data: "[text]", original_data: "[text]", frozen?: boolean }, ... ]
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

  validates :type, presence: true
  validates :status, presence: true
  validates :data_fields, presence: true

  def initialize_data_fields(field_data)
    
    self.data_fields = field_data.map do |value|
      {
        "value" => value,
        "original_value" => value,
        "frozen" => false
      }
    end

  end

  def set_data_field(index, value)
    unless data_fields[index]["frozen"]
      data_fields[index].merge!({
        "value" => value
      })
      data_field_changed(index, value)
    end
  end

  def freeze_data_field(index)
    data_fields[index]["frozen"] = true
  end

  def freeze_all_data_fields
    data_fields.each { |f| f["frozen"] = true }
  end

  private

  def data_field_changed(index, value)
    # Subclasses may re-implement to perform actions when field change
  end
end
