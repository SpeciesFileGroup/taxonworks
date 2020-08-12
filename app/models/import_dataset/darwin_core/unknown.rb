class ImportDataset::DarwinCore::Unknown < ImportDataset::DarwinCore

  attr_accessor :error_message

  before_validation :set_error

  private

  def set_error
    errors[:source] << error_message if error_message
  end

end