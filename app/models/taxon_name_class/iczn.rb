class TaxonNameClass::Iczn < TaxonNameClass

  def self.code_applicability_start_year
    1758
  end

  def self.code_applicability_end_year
    9999
  end

  def self.applicable_ranks
    ICZN.to_s
  end
end
