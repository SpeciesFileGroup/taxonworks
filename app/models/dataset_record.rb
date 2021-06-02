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

  validates :type, presence: true
  validates :status, presence: true

  after_create :create_fields
  after_update :update_fields
  before_destroy :destroy_fields

  # has_many has serious performance consequences when deleting an import dataset, so using class method instead
  def dataset_record_fields
    DatasetRecordField.where(dataset_record: self)
  end

  def initialize_data_fields(field_data)
    @data_fields = []
    field_data.each_with_index do |value, index|
      @data_fields[index] = (value.blank? ? nil : value)
    end
    @data_field_changed = Array.new(@data_fields.size)
  end

  def data_fields
    unless @data_fields
      @data_fields = self.dataset_record_fields
        .pluck(:position, :value)
        .inject([]) { |a, f| a[f[0]] = f[1]; a }
      @data_field_changed = Array.new(@data_fields.size)
    end

    @data_fields
  end

  def get_data_field(index)
    self.data_fields[index]
  end

  def set_data_field(index, value)
    unless frozen_fields?
      old = self.data_fields[index]
      self.data_fields[index] = value

      begin
        data_field_changed(index, value)
        @data_field_changed[index] = true
      rescue
        self.data_fields[index] = value
        raise
      end
    end
  end

  def frozen_fields?
    self.status == 'Imported'
  end

  private

  def data_field_changed(index, value)
    # Subclasses may re-implement to perform actions when field change
  end

  def field_db_attributes(position, value)
    {
      position: position,
      value: value,
      dataset_record_id: id,
      project_id: project_id,
      import_dataset_id: import_dataset_id,
      encoded_dataset_record_type: DatasetRecordField.encode_record_type(self.class)
    } if value
  end

  def fields_db_attributes
    data_fields.filter_map.with_index { |v, p| field_db_attributes(p, v) }
  end

  def create_fields
    attributes = fields_db_attributes
    DatasetRecordField.insert_all(attributes) if attributes.any?
  end

  def update_fields
    upsert_fields = @data_field_changed
      &.filter_map&.with_index { |c, i| field_db_attributes(i, data_fields[i]) if c } || []
    delete_fields = @data_field_changed
      &.filter_map&.with_index { |c, i| i if c && data_fields[i].blank? } || []

    DatasetRecordField.upsert_all(upsert_fields, unique_by: [:dataset_record_id, :position]) if upsert_fields.any?
    dataset_record_fields.where(position: delete_fields).delete_all if delete_fields.any?
  end

  def destroy_fields
    dataset_record_fields.delete_all
  end
end
