class TaxonNameClass

  # Return a String with the "common" name for this class.
  def self.class_name
    n = self.name.demodulize.underscore.humanize.downcase
  end
end
