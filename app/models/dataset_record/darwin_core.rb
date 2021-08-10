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
    index = get_field_mapping(field_name)

    value = data_fields[index] if index
    normalize_value!(value)

    value.clone unless value.blank?
  end

  def get_tw_data_attribute_fields_for(subject_class)
    get_fields_mapping.keys
    .select { |f| f.is_a?(String) }
    .map do |field|
      /(TW:DataAttribute:#{Regexp.escape(subject_class)}:).+/i =~ field
      {field: field, selector: field.sub($1, '')} if $1
    end
    .reject(&:nil?)
  end

  def get_tw_fields_for(subject_class)
    get_fields_mapping.keys
    .select { |f| f.is_a?(String) }
    .map do |field|
      /(TW:#{Regexp.escape(subject_class)}:).+/i =~ field
      {field: field, name: field.sub($1, '').downcase.to_sym} if $1
    end
    .reject(&:nil?)
  end

  private

  # Re-implemented method from DatasetRecord
  def data_field_changed(index, value)
    term_value_changed(get_fields_mapping[index], value)
  end

  # Subclasses may re-implement to react to value changes
  def term_value_changed(name, value); end

  def get_fields_mapping
    @fields_mapping ||= import_dataset.metadata["core_headers"].reject(&:nil?).each.with_index.inject({}) { |m, (h, i)| m.merge({ h.downcase => i, i => h}) }
  end

  def get_field_mapping(field_name)
    get_fields_mapping[field_name.to_s.downcase]
  end

  def normalize_value!(value)
    value&.gsub!(/^[[:space:]]+|[[:space:]]+$/, '') # strip method doesn't deal with https://en.wikipedia.org/wiki/Non-breaking_space
    value&.squeeze!(" ")
  end

end
