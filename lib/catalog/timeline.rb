
# Filtering attributes
#
# data-
#   origin: 'Original' Filter should be on 'otu' vs. everything else
#   is_subsequent, 'Current' : if multiple citations, then true if is_original OR first in order if none is_original 
#
#   valid: true if object is a valid name, or object is otu and linked to valid_name ?
#
class Catalog::Timeline < Catalog

  def build
    catalog_targets.each do |t|
      @entries.push Catalog::Otu::Entry.new(t)
      @entries.push Catalog::Nomenclature::Entry.new(t.taxon_name) if t.taxon_name
    end
  end

end

