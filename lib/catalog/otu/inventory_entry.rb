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

    # Handle through relations
    # Separate simple through relations from complex/nested ones
    simple_through = []
    complex_through = []

    through_relations.each do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)
      through_reflection = reflection.through_reflection

      # Check if the through association is itself a through association (nested/multi-hop)
      if through_reflection.through_reflection
        complex_through << relation_name
      else
        simple_through << relation_name
      end
    end

    # Handle simple through relations with manual joins
    simple_through.each do |relation_name|
      reflection = Otu.reflect_on_association(relation_name)
      through_reflection = reflection.through_reflection
      source_reflection = reflection.source_reflection

      # Step 1: Get the intermediate (through) records
      if through_reflection.belongs_to?
        # Case A: Otu belongs_to intermediate (e.g., Otu -> protonym -> type_materials)
        through_foreign_key = through_reflection.foreign_key
        through_ids = coordinate_otus.values.map { |otu| otu.send(through_foreign_key) }.compact.uniq
        next if through_ids.empty?

        through_records = through_reflection.klass.where(id: through_ids).to_a
        next if through_records.empty?

        through_to_otus = coordinate_otus.values.group_by { |otu| otu.send(through_foreign_key) }

      else
        # Case B: Intermediate has_many/belongs_to Otu (e.g., Otu <- depictions -> image)
        through_query = through_reflection.klass.where(through_reflection.foreign_key => coordinate_otu_ids)

        if through_reflection.type
          through_query = through_query.where(through_reflection.type => 'Otu')
        end

        through_records = through_query.to_a
        next if through_records.empty?

        otu_to_through = through_records.group_by { |tr| tr.send(through_reflection.foreign_key) }
      end

      # Step 2: Get the target objects from the through records
      if source_reflection.belongs_to?
        # Check if source is polymorphic
        if source_reflection.polymorphic?
          # For polymorphic sources, we need to group by type and query each type separately
          target_foreign_key = source_reflection.foreign_key
          target_type_column = source_reflection.foreign_type

          # Group through records by target type
          records_by_type = through_records.group_by { |tr| tr.send(target_type_column) }

          all_targets = []
          records_by_type.each do |type_name, type_records|
            next if type_name.nil?

            target_klass = type_name.constantize rescue next
            target_ids = type_records.map { |tr| tr.send(target_foreign_key) }.compact.uniq
            next if target_ids.empty?

            targets_for_type = target_klass.where(id: target_ids).includes(citations: :source).to_a
            all_targets.concat(targets_for_type)
          end

          next if all_targets.empty?

          # Build map: through_record_id -> target
          through_to_target = through_records.each_with_object({}) do |tr, hash|
            target_id = tr.send(target_foreign_key)
            target_type = tr.send(target_type_column)
            # Match by ID and type (using is_a? to handle STI properly)
            hash[tr.id] = all_targets.find do |t|
              t.id == target_id && (t.class.name == target_type || t.is_a?(target_type.constantize))
            end
          end

        else
          # Non-polymorphic belongs_to
          target_foreign_key = source_reflection.foreign_key
          target_ids = through_records.map { |tr| tr.send(target_foreign_key) }.compact.uniq
          next if target_ids.empty?

          targets = source_reflection.klass.where(id: target_ids).includes(citations: :source).to_a
          next if targets.empty?

          through_to_target = through_records.each_with_object({}) do |tr, hash|
            target_id = tr.send(target_foreign_key)
            hash[tr.id] = targets.find { |t| t.id == target_id }
          end
        end

      else
        target_foreign_key = source_reflection.foreign_key
        through_ids = through_records.map(&:id).uniq

        targets = source_reflection.klass.where(target_foreign_key => through_ids).includes(citations: :source).to_a
        next if targets.empty?

        through_to_targets = targets.group_by { |t| t.send(target_foreign_key) }
      end

      # Step 3: Connect OTUs -> through records -> targets -> citations
      if through_reflection.belongs_to?
        through_to_otus.each do |through_id, otus_referencing_it|
          through_record = through_records.find { |tr| tr.id == through_id }
          next unless through_record

          if source_reflection.belongs_to?
            target = through_to_target[through_record.id]
            targets_for_through = target ? [target] : []
          else
            targets_for_through = through_to_targets[through_record.id] || []
          end

          otus_referencing_it.each do |otu|
            targets_for_through.each do |target|
              target.citations.each do |citation|
                @items << Catalog::Otu::InventoryEntryItem.new(
                  object: target,
                  base_object: otu,
                  citation: citation,
                  nomenclature_date: citation.source&.cached_nomenclature_date,
                  current_target: entry_item_matches_target?(otu, object)
                )
              end
            end
          end
        end

      else
        otu_to_through.each do |otu_id, otu_through_records|
          base_otu = coordinate_otus[otu_id]

          otu_through_records.each do |through_record|
            if source_reflection.belongs_to?
              target = through_to_target[through_record.id]
              targets_for_through = target ? [target] : []
            else
              targets_for_through = through_to_targets[through_record.id] || []
            end

            targets_for_through.each do |target|
              target.citations.each do |citation|
                @items << Catalog::Otu::InventoryEntryItem.new(
                  object: target,
                  base_object: base_otu,
                  citation: citation,
                  nomenclature_date: citation.source&.cached_nomenclature_date,
                  current_target: entry_item_matches_target?(base_otu, object)
                )
              end
            end
          end
        end
      end
    end

    # Handle complex/nested through relations with eager loading (fallback)
    unless complex_through.empty?
      includes_hash = complex_through.each_with_object({}) do |rel, hash|
        hash[rel] = { citations: :source }
      end

      coordinate_otus_with_includes = ::Otu.where(id: coordinate_otu_ids).includes(includes_hash).to_a

      coordinate_otus_with_includes.each do |otu|
        complex_through.each do |relation_name|
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
