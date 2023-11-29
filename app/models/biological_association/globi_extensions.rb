require_relative 'dwc_extensions'

module BiologicalAssociation::GlobiExtensions

  extend ActiveSupport::Concern

  included do

    GLOBI_EXTENSION_MAP = {
      sourceOccurrenceId: :globi_source_occurrence_id,
      sourceCatalogNumber: :globi_source_catalog_number,
      sourceCollectionCode: :globi_source_collection_code,
      sourceCollectionId: nil,
      sourceInstitutionCode: :globi_source_institution_code,
      sourceTaxonId: nil,
      sourceTaxonName: :globi_source_taxon_name,
      sourceTaxonRank: :globi_source_taxon_rank,
      sourceTaxonPathIds: nil,
      sourceTaxonPath: :globi_source_taxon_path,
      sourceTaxonPathNames: nil,
      sourceBodyPartId: nil,
      sourceBodyPartName: nil,
      sourceLifeStageId: :globi_source_life_stage_id,
      sourceLifeStageName: :globi_source_life_stage_name,
      sourceSexId: :globi_source_sex_id,
      sourceSexName: :globi_source_sex_name,
      interactionTypeId: :globi_interaction_type_id,
      interactionTypeName: :globi_interaction_type_name,
      targetOccurrenceId: :globi_target_occurrence_id,
      targetCatalogNumber: :globi_target_catalog_number,
      targetCollectionCode: :globi_target_collection_code,
      targetCollectionId: nil,
      targetInstitutionCode: :globi_target_institution_code,
      targetTaxonId: nil,
      targetTaxonName: :globi_target_taxon_name,
      targetTaxonRank: :globi_target_taxon_rank,
      targetTaxonPathIds: nil,
      targetTaxonPath: :globi_target_taxon_path,
      targetTaxonPathNames: nil,
      targetBodyPartId: nil,
      targetBodyPartName: nil,
      targetLifeStageId: :globi_target_life_stage_id,
      targetLifeStageName: :globi_target_life_stage_name,
      targetSexId: :globi_target_sex_id,
      targetSexName: :globi_target_sex_name,
      basisOfRecordId: nil,                          # Basis of *which* record?
      basisOfRecordName: nil,
      'http://rs.tdwg.org/dwc/terms/eventDate': nil, # Basis of *which* event date
      decimalLatitude: nil,
      decimalLongitud: nil,
      localityId: nil,
      localityName: nil,
      referenceDoi: nil,
      referenceUrl: nil,
      referenceCitation: nil,
      namespace: nil,
      citation: nil,


      # Some of these are clearly GLOBI specific and will be removed

      archiveURI: nil,
      lastSeenAt: nil,
      contentHash: nil,  
      eltonVersion: nil,
    }.freeze
  end

  # Don't use dwc_
  def globi_extension_row
    r = []
    Export::Csv::Globi::HEADERS.each do |h|
      if m = GLOBI_EXTENSION_MAP[h.to_sym]
        r.push send(m)
      else
        r.push nil
      end
    end
    r
  end

  # TODO: use alias
  def globi_source_occurrence_id


    if biological_association_subject_type == 'CollectionObject'
      biological_association_object.dwc_occurrence_id
    end

    #     dwc_resource_id
  end

  def globi_source_catalog_number
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.dwc_catalog_number
    end
  end

  def globi_source_collection_code
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.dwc_collection_code
    end
  end

  def globi_source_institution_code
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.dwc_institution_code
    else
    end
  end

  def globi_source_taxon_name
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.dwc_scientific_name
    else
      dwc_resource
    end
  end

  def globi_source_taxon_rank
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.dwc_taxon_rank
    else
      biological_association_subject.taxon_name&.rank
    end
  end

  def globi_source_taxon_path
    ApplicationController.helpers.ancestry_path(biological_association_subject.ancestry)
  end

  def globi_source_life_stage_id
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:lifeStage])
        .pluck(:uri)&.join(', ').presence
    else
      nil # Maybe some OTU data attribute property list as above
    end
  end

  def globi_source_life_stage_name
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.dwc_life_stage
    else
      nil # Maybe some OTU data attribute property list
    end
  end

  def globi_source_sex_id
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:sex])
        .pluck(:uri)&.join(', ').presence
    else
      nil # Maybe some OTU data attribute property list as above
    end
  end

  def globi_source_sex_name
    if biological_association_subject_type == 'CollectionObject'
      biological_association_subject.dwc_sex
    else
      nil # Maybe some OTU data attribute property list
    end
  end


  # ---

  def globi_interaction_type_id
    dwc_relationship_of_resource_id
  end

  def globi_interaction_type_name
    dwc_relationship_of_resource
  end

  # ----


  # TODO: use alias
  def globi_target_occurrence_id
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_occurrence_id
    end
  end

  def globi_target_catalog_number
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_catalog_number
    end
  end

  def globi_target_collection_code
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_collection_code
    end
  end

  def globi_target_institution_code
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_institution_code
    else
    end
  end

  def globi_target_taxon_name
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_scientific_name
    else
      dwc_/get
    end
  end

  def globi_target_taxon_rank
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_taxon_rank
    else
      biological_association_object.taxon_name&.rank
    end
  end

  def globi_target_taxon_path
    ApplicationController.helpers.ancestry_path(biological_association_object.ancestry)
  end

  def globi_target_life_stage_id
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:lifeStage])
        .pluck(:uri)&.join(', ').presence
    else
      nil # Maybe some OTU data attribute property list as above
    end
  end

  def globi_target_life_stage_name
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_life_stage
    else
      nil # Maybe some OTU data attribute property list
    end
  end

  def globi_target_sex_id
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:sex])
        .pluck(:uri)&.join(', ').presence
    else
      nil # Maybe some OTU data attribute property list as above
    end
  end

  def globi_target_sex_name
    if biological_association_object_type == 'CollectionObject'
      biological_association_object.dwc_sex
    else
      nil # Maybe some OTU data attribute property list
    end
  end

end
