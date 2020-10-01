class DatasetRecord::DarwinCore < DatasetRecord
  # self.abstract_class = true # TODO: No known problems, but commented since ImportDataset::DarwinCore also has it commented. Review.

  class InvalidData < StandardError
    attr_accessor :error_data

    def initialize(error_data)
      super("Invalid data")
      self.error_data = error_data
    end
  end

  def get_field_value(field_name)
    index = get_fields_mapping[field_name.to_s]

    value = data_fields[index]&.dig("value") if index
    value&.strip!
    value&.squeeze!(" ")

    value unless value.blank?
  end

  private

  def get_fields_mapping
    @fields_mapping ||= import_dataset.metadata["core_headers"].each.with_index.inject({}) { |m, (h, i)| m.merge({ h => i, i => h}) }
  end

end
