# A Catalog::Entry that contains the biological history of an otu via associated
# data of that otu (images, asserted distributions, observations, etc.).
class Catalog::Otu::InventoryEntry < ::Catalog::Entry

  attr_accessor :include_belongs_to

  # nomenclature catalog typically handles citations on taxon_name, so by
  # default we don't process belongs_to relations on otu.
  def initialize(otu, include_belongs_to: false)
    @include_belongs_to = include_belongs_to
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

    # Filter out STI subclass relations that are redundant with their parent class
    # (e.g., `protonyn` belongs_to duplicates `taxon_name` belongs_to)
    relation_names = relation_names.reject do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)
      # Check if this relation's class is a subclass of any other relation's class
      relation_names.any? do |other_relation_name|
        next if relation_name == other_relation_name
        other_reflection = Otu.reflect_on_association(other_relation_name)
        reflection.klass < other_reflection.klass
      end
    end

    # Load all coordinate OTUs once and build a lookup hash.
    # Include taxon_name with nested associations to avoid N+1 queries when
    # rendering.
    coordinate_otus = ::Otu.where(id: coordinate_otu_ids)
      .includes(taxon_name: [:taxon_name_classifications, :taxon_name_relationships])
      .index_by(&:id)

    belongs_to_relations = []
    has_one_relations = []
    has_many_relations = []
    through_relations = []

    relation_names.each do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)
      if reflection.through_reflection
        through_relations << relation_name
      elsif reflection.macro == :belongs_to
        belongs_to_relations << relation_name
      elsif reflection.macro == :has_one
        has_one_relations << relation_name
      elsif reflection.macro == :has_many
        has_many_relations << relation_name
      end
    end

    if include_belongs_to
      process_belongs_to_relations(belongs_to_relations, coordinate_otus)
    end

    # has_one and has_many use the same foreign key logic
    process_has_many_relations(has_one_relations + has_many_relations, coordinate_otus)

    process_through_relations(through_relations, coordinate_otu_ids)

    @items.uniq! { |item| [item.citation.id, item.object.class.name, item.object.id] }
  end

  private

  def process_belongs_to_relations(belongs_to_relations, coordinate_otus)
    belongs_to_relations.each do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)
      relation_klass = reflection.klass
      foreign_key = reflection.foreign_key

      # Get target IDs that coordinate OTUs reference
      target_ids = coordinate_otus.values.map { |otu| otu.send(foreign_key) }.compact.uniq
      next if target_ids.empty?

      # Build a map of which OTU references which target
      otu_to_target = coordinate_otus.transform_values { |otu| otu.send(foreign_key) }

      # Query citations directly on the target objects
      citations = Citation
        .where(citation_object_type: relation_klass.name, citation_object_id: target_ids)
        .includes(:source, :notes, :citation_object)
        .to_a

      citations.each do |citation|
        associated_object = citation.citation_object

        # Find which coordinate OTUs reference this object
        referencing_otu_ids = otu_to_target.select { |otu_id, target_id| target_id == associated_object.id }.keys

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
  end

  # Processes has_one and has_many relations (both use foreign key logic).
  # !! Does not process :through relations.
  def process_has_many_relations(has_many_relations, coordinate_otus)
    coordinate_otu_ids = coordinate_otus.keys

    has_many_relations.each do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)
      relation_klass = reflection.klass
      foreign_key = reflection.foreign_key

      citation_query = Citation
        .joins("INNER JOIN #{relation_klass.table_name} ON citations.citation_object_type = '#{relation_klass.name}' AND citations.citation_object_id = #{relation_klass.table_name}.id")
        .where("#{relation_klass.table_name}.#{foreign_key}" => coordinate_otu_ids)

      # Handle polymorphic associations (e.g., otu_id with otu_type = 'Otu')
      if reflection.type
        citation_query = citation_query.where("#{relation_klass.table_name}.#{reflection.type}" => 'Otu')
      end

      # Eager load citation associations and the cited object for views.
      # For BiologicalAssociations, preload subject/object and their taxon_names with nested associations
      if relation_klass.name == 'BiologicalAssociation'
        citations = citation_query
          .includes(
            :source,
            :notes,
            :topics,
            {
              citation_object: [
                { biological_association_subject: { taxon_name: [:taxon_name_classifications, :taxon_name_relationships] } },
                { biological_association_object: { taxon_name: [:taxon_name_classifications, :taxon_name_relationships] } }
              ]
            }
          )
          .to_a
      else
        citations = citation_query
          .includes(:source, :notes, :topics, :citation_object)
          .to_a
      end

      citations.each do |citation|
        associated_object = citation.citation_object
        base_otu_id = associated_object.send(foreign_key)
        base_otu = coordinate_otus[base_otu_id]

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

  def process_through_relations(through_relations, coordinate_otu_ids)
    return if through_relations.empty?

    # Attempting to build custom joins for through relations a la
    # #process_has_many_relations is complex due to:
    # - STI tables (e.g., protonym → taxon_names table)
    # - Polymorphic sources
    # - Different join patterns for each through type
    # So here we just let rails handle everything.
    includes_hash = through_relations.each_with_object({}) do |rel, hash|
      hash[rel] = { citations: [:source, :notes, :topics] } # for views
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

  # @return [Boolean]
  def entry_item_matches_target?(item_object, reference_object)
    item_object.taxon_name_id == reference_object.taxon_name_id
  end

end
