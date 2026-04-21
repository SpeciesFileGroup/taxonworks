class Catalog::Inventory < ::Catalog

  def build
    catalog_targets.each do |t|
      @entries.push(Catalog::Otu::InventoryEntry.new(t))
    end
    true
  end

  # @return [Hash{ Integer => Hash }]
  #   Keyed by coordinate OTU id (the base_object of each item).
  #   Each value is a hash containing the OTU and its citations, one per
  #   unique (type, source) pair for that OTU, with topics unioned across
  #   all items of that pair.
  #   { otu_id => { otu: Otu,
  #                 citations: [ { id: Integer, citation_object_type: String, source: Source,
  #                                pages: String, is_original: Boolean,
  #                                topics: [Topic] }, ... ] } }
  def citations_summary
    items.group_by { |item| item.base_object.id }
      .transform_values do |otu_items|
        otu = otu_items.first.base_object

        {
          otu: otu,
          citations: otu_items
            .group_by { |item| [item.object.class.name, item.citation&.source_id] }
            .map do |(type, _source_id), grouped_items|
              {
                id: grouped_items.first.citation&.id,
                type: type,
                source: grouped_items.first.citation&.source,
                pages: grouped_items.first.citation&.pages,
                is_original: grouped_items.first.citation&.is_original,
                topics: grouped_items.flat_map(&:topics).uniq
              }
            end
        }
      end
  end

end
