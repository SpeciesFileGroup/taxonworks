# A Catalog::Timeline is a catalog that merges biolgological concepts (OTUs) with their nomenclature.
#
# Filtering intent:
#   Level 1: [Nomenclature, Protonym, OTU (biology)] - mutually exclusive
#   Level 2 (All): [First, Valid]
#
# Visualizing intent:
#   [Origin] tag
class Catalog::Timeline < Catalog

  def build
    catalog_targets.each do |t|
      @entries.push Catalog::Otu::Entry.new(t)
      @entries.push Catalog::Nomenclature::Entry.new(t.taxon_name) if t.taxon_name
    end
  end

end

