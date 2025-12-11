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
    project_id = object.project_id
    relation_metadata = ApplicationEnumeration.citable_relations_metadata(Otu)

    relation_metadata.each do |meta|
      begin
        target_class = meta[:target_class].constantize
        target_table = target_class.table_name
        join_type = meta[:join_type]
        details = meta[:join_details]

        # Build the query based on join type
        citations_query = Citation
          .joins("INNER JOIN #{target_table} ON citations.citation_object_type = '#{meta[:target_class]}' AND citations.citation_object_id = #{target_table}.id")

        case join_type
      when :through
        # For has_many :through (e.g., images through depictions)
        # Join: citation -> target_class (e.g., Image) -> through_class (e.g., Depiction) -> Otu
        through_table = details[:through_table]

        # Determine join strategy based on polymorphic nature of relationships
        if details[:source_foreign_type]
          # Source is polymorphic (e.g., collection_objects through taxon_determinations)
          # Join: CollectionObject <- TaxonDetermination (taxon_determination_object_id + type) where otu_id in coordinate_otu_ids
          # Through table has polymorphic foreign key pointing to target
          citations_query = citations_query
            .joins("INNER JOIN #{through_table} ON #{target_table}.id = #{through_table}.#{details[:source_foreign_key]} AND #{through_table}.#{details[:source_foreign_type]} = '#{meta[:target_class]}'")
            .where(through_table => { details[:through_foreign_key] => coordinate_otu_ids })
        elsif details[:through_foreign_type]
          # Through is polymorphic (e.g., images through depictions)
          # Join: Image <- Depiction (image_id) where depiction_object_type='Otu' and depiction_object_id in coordinate_otu_ids
          # Through table has foreign key pointing to target: Depiction.image_id = Image.id
          citations_query = citations_query
            .joins("INNER JOIN #{through_table} ON #{target_table}.id = #{through_table}.#{details[:source_foreign_key]}")
            .where(through_table => {
              details[:through_foreign_type] => 'Otu',
              details[:through_foreign_key] => coordinate_otu_ids
            })
        else
          # Non-polymorphic through (e.g., type_materials through protonym)
          # Join: TypeMaterial -> TaxonName (protonym_id) -> Otu (taxon_name_id)
          # Target table has foreign key pointing to through: TypeMaterial.protonym_id = TaxonName.id
          otu_table = ::Otu.table_name
          citations_query = citations_query
            .joins("INNER JOIN #{through_table} ON #{target_table}.#{details[:source_foreign_key]} = #{through_table}.id")
            .joins("INNER JOIN #{otu_table} ON #{otu_table}.#{details[:through_foreign_key]} = #{through_table}.id")
            .where(otu_table => { id: coordinate_otu_ids })
        end

      when :polymorphic
        # For polymorphic associations (e.g., biological_associations)
        # Join: citation -> target_class -> Otu (via polymorphic foreign key)
        citations_query = citations_query
          .where(target_table => {
            details[:foreign_type] => 'Otu',
            details[:foreign_key] => coordinate_otu_ids
          })

      when :belongs_to
        # For belongs_to relationships (e.g., Otu belongs_to taxon_name)
        # Join: citation -> target_class (e.g., TaxonName) <- Otu (Otu.taxon_name_id = TaxonName.id)
        # The foreign key is in the Otu table, not the target table
        otu_table = ::Otu.table_name
        citations_query = citations_query
          .joins("INNER JOIN #{otu_table} ON #{otu_table}.#{details[:foreign_key]} = #{target_table}.#{details[:primary_key]}")
          .where(otu_table => { id: coordinate_otu_ids })

      when :direct
        # For direct has_many (e.g., has_many :taxon_determinations)
        # The foreign key is in the target table
        citations_query = citations_query
          .where(target_table => { details[:foreign_key] => coordinate_otu_ids })
      end

      # Add project filter where applicable
      if target_class.column_names.include?('project_id')
        citations_query = citations_query.where(target_table => { project_id: project_id })
      end

      # Eager load the citation_object and source for efficiency
      citations_query = citations_query.includes(:citation_object, :source)

      # Create entry items
      citations_query.find_each do |citation|
        cited_object = citation.citation_object

        # Find the base OTU for this citation
        base_otu_id = case join_type
        when :through
          # Get the through object to find the OTU
          through_class = details[:through_class].constantize
          if details[:through_foreign_type]
            # Polymorphic through
            through_obj = through_class.find_by(
              details[:through_foreign_type] => 'Otu',
              details[:source_foreign_key] => cited_object.id
            )
            through_obj&.send(details[:through_foreign_key])
          else
            # Non-polymorphic through
            through_obj = through_class.find_by(
              details[:source_foreign_key] => cited_object.id,
              details[:through_foreign_key] => coordinate_otu_ids
            )
            through_obj&.send(details[:through_foreign_key])
          end
        when :polymorphic
          cited_object.send(details[:foreign_key]) if cited_object.send(details[:foreign_type]) == 'Otu'
        when :belongs_to
          # For belongs_to, we need to find which OTU references this cited_object
          # e.g., find Otu where Otu.taxon_name_id = cited_object.id
          otu = ::Otu.where(details[:foreign_key] => cited_object.id)
            .where(id: coordinate_otu_ids)
            .first
          otu&.id
        when :direct
          cited_object.send(details[:foreign_key])
        end

        base_otu = ::Otu.find_by(id: base_otu_id) if base_otu_id

        @items << Catalog::Otu::InventoryEntryItem.new(
          object: cited_object,
          base_object: base_otu,
          citation: citation,
          nomenclature_date: citation.source&.cached_nomenclature_date,
          current_target: base_otu ? entry_item_matches_target?(base_otu, object) : false
        )
      end
      rescue ActiveRecord::StatementInvalid => e
        # Skip relations that cause SQL errors
        # Known limitations:
        # - Multi-level chained through relationships (e.g., extracts -> collection_objects -> taxon_determinations)
        # - STI-based through relationships with alias classes (e.g., type_materials through Protonym)
        # These edge cases could be addressed with more complex join logic if needed
        Rails.logger.warn("Skipping relation #{meta[:relation_name]} due to SQL error: #{e.message}")
        next
      end
    end

    # Remove duplicates (same citation_id and object combination)
    # This can happen when multiple relations point to the same underlying record (e.g., taxon_name and protonym)
    @items.uniq! { |item| [item.citation.id, item.object.class.name, item.object.id] }
  end

  # @return [Boolean]
  #   this is the MM result
  def entry_item_matches_target?(item_object, reference_object)
    item_object.taxon_name_id == reference_object.taxon_name_id
  end

end
