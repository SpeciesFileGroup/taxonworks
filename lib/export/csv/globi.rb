# CSV for for a ResourceRelationship based extension
# 
module Export::CSV::Globi

  # See also  BiologicalAssociation::DwcExtensions::DWC_EXTENSION_MAP, the two play off each other.
  # Maintain this for order.
  HEADERS = %w{
    sourceOccurrenceId
    sourceCatalogNumber
    sourceCollectionCode
    sourceCollectionId:
    sourceInstitutionCode
    sourceTaxonId
    sourceTaxonName
    sourceTaxonRank
    sourceTaxonPathIds
    sourceTaxonPath
    sourceTaxonPathNames
    sourceBodyPartId
    sourceBodyPartName
    sourceLifeStageId
    sourceLifeStageName
    sourceSexId
    sourceSexName
    interactionTypeId
    interactionTypeName
    targetOccurrenceId
    targetCatalogNumber
    targetCollectionCode
    targetCollectionId
    targetInstitutionCode
    targetTaxonId
    targetTaxonName
    targetTaxonRank
    targetTaxonPathIds
    targetTaxonPath
    targetTaxonPathNames
    targetBodyPartId
    targetBodyPartName
    targetLifeStageId
    targetLifeStageName
    targetSexId
    targetSexName
    basisOfRecordId
    basisOfRecordName
    'http://rs.tdwg.org/dwc/terms/eventDate'
    decimalLatitude
    decimalLongitud
    localityId
    localityName
    referenceDoi
    referenceUrl
    referenceCitation
    namespace
    citation
    archiveURI
    lastSeenAt
    contentHash
    eltonVersion: nil
  }.freeze

  def self.csv(scope)
    tbl = []
    tbl[0] = HEADERS

    scope.find_each do |b|
      tbl << b.globi_extension_row
    end

    output = StringIO.new
    tbl.each do |row|
      output.puts CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end

end
