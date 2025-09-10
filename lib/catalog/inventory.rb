class Catalog::Inventory < ::Catalog

  def build
    catalog_targets.each do |t|
      @entries.push(Catalog::Otu::InventoryEntry.new(t))
    end
    true
  end

end

