# A Catalog::Entry that contains the biological history of an otu via associated
# data of that otu (images, asserted distributions, observations, etc.).
class Catalog::Otu::InventoryEntry < ::Catalog::Entry

  def initialize(otu)
    super(otu)
    true
  end

  def build
    from_self
    true
  end

  def to_html_method
    :otu_catalog_entry_item_to_html
  end

  def from_self
    a = ::Otu.coordinate_otus(object.id).load
    b = ApplicationEnumeration.citable_relations(Otu).values.flatten(1)

    a.each do |o|
      b.each do |r|
        association = o.send(r)
        association = [association] if !association.is_a?(Enumerable)
        association.each do |x|
          x.citations.each do |c|
            @items << Catalog::Otu::InventoryEntryItem.new(
              object: x,
              base_object: o,
              citation: c,
              nomenclature_date: c.source&.cached_nomenclature_date,
              current_target: entry_item_matches_target?(o, object)
            )
          end
        end
      end
    end
  end

  # @return [Boolean]
  #   this is the MM result
  def entry_item_matches_target?(item_object, reference_object)
    item_object.taxon_name_id == reference_object.taxon_name_id
  end

end
