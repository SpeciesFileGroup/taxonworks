class DatasetRecord::DarwinCore < DatasetRecord
  # self.abstract_class = true # TODO: No known problems, but commented since ImportDataset::DarwinCore also has it commented. Review.

  class InvalidData < StandardError
    attr_accessor :error_data

    def initialize(error_data)
      super("Invalid data")
      self.error_data = error_data
    end
  end

end
