class TaxonNameClass::Icn < TaxonNameClass
  def self.applicable_ranks
    ICN.to_s
  end
end
