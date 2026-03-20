class Catalog::Inventory < ::Catalog

  def build
    catalog_targets.each do |t|
      @entries.push(Catalog::Otu::InventoryEntry.new(t))
    end
    true
  end

  # @return [Array of Hash]
  #   Each hash represents a unique (type, source) pair with topics unioned
  #   across all items of that type from that source.
  #   [ { type: String, source: Source, topics: [Topic] }, ... ]
  def citations_summary
    items.group_by { |item| [item.object.class.name, item.citation&.source_id] }
      .map do |(type, _source_id), grouped_items|
        {
          type: type,
          source: grouped_items.first.citation&.source,
          topics: grouped_items.flat_map(&:topics).uniq
        }
      end
  end

end

