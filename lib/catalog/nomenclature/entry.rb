# A Catalog::Entry that contains the nomenclatural history of a single TaxonName
# Mutiple Catalog::Entries would make up a catalog.

# EntryItems for this Entry must follow the pattern:
# * The `base_object` is always a TaxonName
# * The `object` may be a Protony, TaxonNameRelationship, or Combination
#
class Catalog::Nomenclature::Entry < Catalog::Entry

  def initialize(taxon_name)
    super(taxon_name)
  end

  def build
    v = object.valid_taxon_name
    base_names = v.historical_taxon_names
    base_names.each do |t|

      items << Catalog::Nomenclature::EntryItem.new(object: t, base_object: t, citation: nil, nomenclature_date: t.nomenclature_date) if !t.citations.load.any? # TODO: base_object correct

      t.citations.each do |c|
        items << Catalog::Nomenclature::EntryItem.new(object: t, base_object: t, citation: c, nomenclature_date: c.source.cached_nomenclature_date) # TODO: base_object correct?
      end

      ::TaxonNameRelationship.where_subject_is_taxon_name(t).with_type_array(STATUS_TAXON_NAME_RELATIONSHIP_NAMES).each do |r|

        if !r.citations.load.any?
          items << Catalog::Nomenclature::EntryItem.new(
            object: r,
            base_object: r.subject_taxon_name,
            citation: nil,
            nomenclature_date: r.subject_taxon_name.nomenclature_date
          )
        end

        r.citations.each do |c|
          items << Catalog::Nomenclature::EntryItem.new(
            object: r,
            base_object: r.subject_taxon_name,
            citation: c,
            nomenclature_date: (c.try(:source).try(:cached_nomenclature_date) || r.subject_taxon_name.nomenclature_date))
        end
      end
    end

    true
  end


  # @return [Array of NomenclatureCatalog::EntryItem]
  #   sorted by date, then taxon name name as rendered for this item
  def ordered_by_nomenclature_date
    now = Time.now
    items.sort{|a,b| [(a.nomenclature_date || now), a.object_class, a.base_object.cached_original_combination.to_s ] <=> [(b.nomenclature_date || now), b.object_class, b.base_object.cached_original_combination.to_s ] }
  end

  # @return [Array]
  def names
    @names ||= all_names
    @names
  end

  protected

  # @param [CatalogEntry] catalog_item
  # @return [Array]
  def item_names(catalog_item)
    [object, catalog_item.base_object, catalog_item.other_name].compact.uniq
  end

  # @return [Array of TaxonName]
  #   a summary of all names referenced in this entry 
  def all_names
    n = [ object ]
    items.each do |i|
      n.push item_names(i)
    end
    n.flatten.uniq.sort_by!(&:cached)
    n
  end

  # @return [Array of Sources]
  #   as extracted for all EntryItems, orderd alphabetically by full citation
  def all_sources
    s  = items.collect{|i| i.source}

    if !object.nil?
      relationship_items.each do |i|
        s << i.object.object_taxon_name.origin_citation.try(:source) if i.object.subject_taxon_name != object  # base_object?
        s << i.object.subject_taxon_name.origin_citation.try(:source) if i.object.object_taxon_name != object
      end
    end

    # This is here because they are cross-referenced in HTML rendering
    s += ::TaxonNameClassification.where(taxon_name_id: all_protonyms.collect{|p| p.object}).all.
      collect{|tnc| tnc.citations.collect{|c| c.source}}.flatten

    s.compact.uniq.sort_by{|s| s.cached}
  end

  # @return [Array]
  def all_protonyms
    items.select{|i| i.origin == 'protonym' }
  end

  # @return [Array of EntryItems]
  #   only those entry items that reference a TaxonNameRelationship
  def relationship_items
    items.select{|i| i.object_class =~ /TaxonNameRelationship/}
  end

end
