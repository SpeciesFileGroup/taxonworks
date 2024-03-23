# CSV for for a ResourceRelationship based extension
# 
module Export::CSV::Dwc::Extension::BiologicalAssociations

  # See also  BiologicalAssociation::DwcExtensions::DWC_EXTENSION_MAP, the two play off each other.
  # Maintain this for order.
  HEADERS = %w{
    resourceRelationshipID
    resourceID
    resource
    relationshipOfResourceID
    relationshipOfResource
    relatedResourceID
    relatedResource 
    relationshipAccordingTo
    relationshipEstablishedDate
    relationshipRemarks
  }.freeze

  def self.csv(scope)
    tbl = []
    tbl[0] = HEADERS

    scope.find_each do |b|
      tbl << b.darwin_core_extension_row
    end

    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end


end
