# Helpers for rendering a JSON version of a catalog.
#
# See also the paper catalog version.
#
module TaxonNames::JsonCatalogHelper

  OPTIONS = { }.freeze

  # @return [Hash]
  #
  #  timeline: []
  #  sources: []
  #  respositories: []
  #  distribution: String
  #
  def recursive_catalog_json(taxon_name: nil, target_depth: 0, depth: 0, data: { timeline: [], sources: [], repositories: []} )
    return data if taxon_name.nil?

    cat = ::Catalog::Nomenclature::Entry.new(taxon_name)
    data[:sources] += [cat.sources].flatten

    if target_depth == depth
      # distribution is only calculated for species level here!!
      d = paper_distribution_entry(taxon_name)
      if d && d.items.any?
        data[:distribution] = d.to_s
        # data[:supplementary_distribution].items += d.items
      end
    end

    cat.ordered_by_nomenclature_date.each do |c|
      i = json_catalog_entry_item(catalog_entry_item: c, catalog_object: cat.object)

      if t = paper_history_type_material(c)
        i[:type_label] = t
        if r = paper_repositories(c)
          data[:repositories].push r
        end
      end

      data[:timeline].push i
    end

    if depth < target_depth
      taxon_name.children.that_is_valid.order(:cached).each do |t|
        recursive_catalog_json(taxon_name: t, depth: depth + 1, target_depth:, data: )
      end
    end

    data
  end

  def json_catalog_entry_item(catalog_entry_item: nil, catalog_object: nil)
    e = {
      label: paper_catalog_li_tag(catalog_entry_item, catalog_object, :browse_nomenclature_task_path),
      year: catalog_entry_item.nomenclature_date&.year,
    }
  end

end
