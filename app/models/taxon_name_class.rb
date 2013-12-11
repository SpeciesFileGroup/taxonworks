class TaxonNameClass

  # Return a String with the "common" name for this class.
  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  # years of applicability for each class
  def self.code_applicability_start_year
    1
  end

  def self.code_applicability_end_year
    9999
  end

  def self.applicable_ranks
    []
  end

end
