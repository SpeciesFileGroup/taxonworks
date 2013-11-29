class TaxonNameClass::Iczn < TaxonNameClass

  def self.code_applicability_start_year
    1758
  end

  def self.applicable_ranks
    ICZN.collect{|t| t.to_s}
  end
end
