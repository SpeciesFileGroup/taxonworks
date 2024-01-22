# zeitwerk removed
# require_dependency Rails.root.to_s + '/lib/catalog/nomenclature/entry.rb'
# require_dependency Rails.root.to_s + '/lib/catalog/otu/entry.rb'

# A Catalog::Timeline is a catalog that merges biolgological concepts (OTUs) with their nomenclature.
#
# Filtering intent:
#   Level 1: [Nomenclature (origin != 'otu'), Protonym (origin == 'protonym', OTU (biology), origin == 'otu'] - mutually exclusive
#   Level 2 (All): [First (is_first: true,) Valid (is_valid: true)]
#
# Visualizing intent:
#   First valid - (origin: protonym, is_valid: true, is_first: true)
#   Origin - (origin)
#
class Catalog::Timeline < ::Catalog

  def build
    catalog_targets.each do |t|
      @entries.push(Catalog::Otu::Entry.new(t))
      @entries.push(Catalog::Nomenclature::Entry.new(t.taxon_name)) if t.taxon_name
    end
    true
  end

end

