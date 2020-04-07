# A DatasetRecord is the unit of data (typically a table row) from an ImportDataset
#
# @!attribute data_fields
#   @return [Hash]
#      data of each record field. Structure: { some_field: {data: "[text]", original_data: "[text]", frozen?: boolean}, another_field: ... }
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
    data_fields = {}

    field_data.each do |field_name, value|
      data_fields[field_name] = {
        "value" => value,
        "original_value" => value,
        "frozen" => false
      }
    end

    self.data_fields = data_fields
  end  
end
