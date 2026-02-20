module BiologicalAssociations
  class CreateWithAnatomicalParts
    attr_reader :biological_association, :errors

    def initialize(params)
      # ActionController::Parameters#to_h returns a HashWithIndifferentAccess
      # recursively, so all nested attributes are accessible by symbol key.
      @params = params.to_h
      @errors = []
      @biological_association = nil
    end

    def call
      ActiveRecord::Base.transaction do
        subject = build_subject
        object = build_object

        @biological_association = BiologicalAssociation.new(base_attributes)

        @biological_association.biological_association_subject = subject
        @biological_association.biological_association_object = object

        @biological_association.save!
      end

      true
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      false
    end

    private

    # Symbol keys work because @params is a HashWithIndifferentAccess (set in #initialize via to_h).
    def base_attributes
      @params.except(
        :subject_anatomical_part_attributes,
        :object_anatomical_part_attributes,
        :subject_taxon_determination_attributes,
        :object_taxon_determination_attributes,
        :biological_association_subject_id,
        :biological_association_subject_type,
        :biological_association_object_id,
        :biological_association_object_type
      )
    end

    def build_subject
      build_association_end(
        id: param(:biological_association_subject_id),
        type: param(:biological_association_subject_type),
        anatomical_part_attributes: param(:subject_anatomical_part_attributes),
        taxon_determination_attributes: param(:subject_taxon_determination_attributes)
      )
    end

    def build_object
      build_association_end(
        id: param(:biological_association_object_id),
        type: param(:biological_association_object_type),
        anatomical_part_attributes: param(:object_anatomical_part_attributes),
        taxon_determination_attributes: param(:object_taxon_determination_attributes)
      )
    end

    def build_association_end(id:, type:, anatomical_part_attributes:, taxon_determination_attributes:)
      origin = type.constantize.find(id)

      return origin if anatomical_part_attributes.blank?

      create_taxon_determination_if_needed(origin, taxon_determination_attributes)

      create_anatomical_part(origin, anatomical_part_attributes)
    end

    def create_taxon_determination_if_needed(origin, taxon_determination_attributes)
      return unless ['CollectionObject'].include?(origin.class.base_class.name)
      return unless origin.taxon_determinations.empty?
      return if taxon_determination_attributes.blank?

      taxon_determination = TaxonDetermination.new(
        taxon_determination_object: origin,
        otu_id: taxon_determination_attributes[:otu_id]
      )

      taxon_determination.save!
    end

    def create_anatomical_part(origin, anatomical_part_attributes)
      attributes = {
        name: anatomical_part_attributes[:name],
        uri: anatomical_part_attributes[:uri],
        uri_label: anatomical_part_attributes[:uri_label],
        is_material: anatomical_part_attributes[:is_material],
        preparation_type_id: anatomical_part_attributes[:preparation_type_id]
      }

      attributes[:is_material] = AnatomicalPart.default_is_material_for(origin) if attributes[:is_material].nil?

      anatomical_part = AnatomicalPart.new(
        attributes.merge(
          inbound_origin_relationship_attributes: {
            old_object_id: origin.id,
            old_object_type: origin.class.base_class.name
          }
        )
      )

      anatomical_part.save!
      anatomical_part
    end

    def param(key)
      @params[key]
    end
  end
end
