class TaxonNameClass::Icn < TaxonNameClass
  def self.applicable_ranks
    ICN.collect{|t| t.to_s}
  end
end
