class TaxonNameClass

  # Return a String with the "common" name for this class.
  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def type_name
    TAXON_NAME_CLASS_NAMES.include?(self.type.to_s) ? self.type.to_s : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type)
    TAXON_NAME_CLASS_NAMES.include?(r) ? r.constantize : r
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

  def self.disjoint_taxon_name_classes
    []
  end

end
