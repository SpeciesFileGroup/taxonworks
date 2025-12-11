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
    coordinate_otu_ids = ::Otu.coordinate_otus(object.id).pluck(:id)
    relation_names = ApplicationEnumeration.citable_relations(Otu).values.flatten(1)

    # Load all coordinate OTUs once and build a lookup hash
    coordinate_otus = ::Otu.where(id: coordinate_otu_ids).index_by(&:id)

    # Separate simple relations from through relations
    simple_relations = []
    through_relations = []

    relation_names.each do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)
      if reflection.through_reflection
        through_relations << relation_name
      else
        simple_relations << relation_name
      end
    end

    # Handle simple relations with bulk queries
    simple_relations.each do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)

      if reflection.macro == :belongs_to
        # belongs_to: get the target objects referenced by coordinate OTUs
        foreign_key = reflection.foreign_key
        target_ids = coordinate_otus.values.map { |otu| otu.send(foreign_key) }.compact.uniq
        next if target_ids.empty?

        associated_objects = reflection.klass.where(id: target_ids).includes(citations: :source).to_a

        # Build a map of which OTU references which target
        otu_to_target = coordinate_otus.transform_values { |otu| otu.send(foreign_key) }

        associated_objects.each do |associated_object|
          # Find which coordinate OTUs reference this object
          referencing_otu_ids = otu_to_target.select { |otu_id, target_id| target_id == associated_object.id }.keys

          associated_object.citations.each do |citation|
            referencing_otu_ids.each do |otu_id|
              base_otu = coordinate_otus[otu_id]
              @items << Catalog::Otu::InventoryEntryItem.new(
                object: associated_object,
                base_object: base_otu,
                citation: citation,
                nomenclature_date: citation.source&.cached_nomenclature_date,
                current_target: entry_item_matches_target?(base_otu, object)
              )
            end
          end
        end

      else
        # has_many: get objects that reference coordinate OTUs
        foreign_key = reflection.foreign_key
        query = reflection.klass.where(foreign_key => coordinate_otu_ids)

        # Handle polymorphic associations
        if reflection.type
          query = query.where(reflection.type => 'Otu')
        end

        associated_objects = query.includes(citations: :source).to_a

        associated_objects.each do |associated_object|
          base_otu_id = associated_object.send(foreign_key)
          base_otu = coordinate_otus[base_otu_id]

          associated_object.citations.each do |citation|
            @items << Catalog::Otu::InventoryEntryItem.new(
              object: associated_object,
              base_object: base_otu,
              citation: citation,
              nomenclature_date: citation.source&.cached_nomenclature_date,
              current_target: entry_item_matches_target?(base_otu, object)
            )
          end
        end
      end
    end

    # Handle through relations using original approach with eager loading
    unless through_relations.empty?
      includes_hash = through_relations.each_with_object({}) do |rel, hash|
        hash[rel] = { citations: :source }
      end

      coordinate_otus_with_includes = ::Otu.where(id: coordinate_otu_ids).includes(includes_hash).to_a

      coordinate_otus_with_includes.each do |otu|
        through_relations.each do |relation_name|
          association = otu.send(relation_name)
          association = [association] if !association.is_a?(Enumerable)

          association.compact.each do |associated_object|
            associated_object.citations.each do |citation|
              @items << Catalog::Otu::InventoryEntryItem.new(
                object: associated_object,
                base_object: otu,
                citation: citation,
                nomenclature_date: citation.source&.cached_nomenclature_date,
                current_target: entry_item_matches_target?(otu, object)
              )
            end
          end
        end
      end
    end

    # Remove duplicates - same citation on same object should only appear once
    @items.uniq! { |item| [item.citation.id, item.object.class.name, item.object.id] }
  end

  # @return [Boolean]
  #   this is the MM result
  def entry_item_matches_target?(item_object, reference_object)
    item_object.taxon_name_id == reference_object.taxon_name_id
  end

end
