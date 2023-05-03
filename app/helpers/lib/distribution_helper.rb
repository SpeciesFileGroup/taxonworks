module Lib::DistributionHelper
  def paper_distribution_entry(taxon_name)
    return nil unless taxon_name.is_species_rank?
    otus = Otu.descendant_of_taxon_name(taxon_name.id)

    return nil if otus.empty?
    ::Catalog::Distribution::Entry.new(otus)
  end
end
