class DatasetRecord::DarwinCore::Occurrence < DatasetRecord

  def import
    # NOT IMPLEMENTED YET
    self.status = "Unsupported"
    self.metadata[:error_data] = {
      messages: { unsupported: ["Only staging occurrence records is supported at this time."] }
    }

    save!
  end

end
