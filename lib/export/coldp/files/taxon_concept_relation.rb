# The target format for CoLDP is:
#
# taxonID
# relatedTaxonID
# sourceID
# type
# referenceID
# remarks
# modified
# modifiedBy
#
#
# TODO: This hasn't been tested IRL.
module Export::Coldp::Files::TaxonConceptRelation

  MAP_TYPES = {
    "OtuRelationship::Intersecting" => "intersecting", # TODO: not included in CLB? http://api.checklistbank.org/vocab/TaxonConceptRelType
    "OtuRelationship::Disjoint" => "excludes",
    "OtuRelationship::Equal" => "equals",
    "OtuRelationship::ProperPartInverse" => "includes",
    "OtuRelationship::ProperPart" => "included in",
    "OtuRelationship::PartiallyOverlapping" => "overlaps",
  }

  def self.type(orel)
    MAP_TYPES[orel.type]
  end

  def self.generate(otus, project_members, reference_csv = nil )
    ::CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
                taxonID
                relatedTaxonID
                sourceID
                type
                referenceID
                remarks
                modified
                modifiedBy
      } 

      a = OtuRelationship.with(otu_scope: otus.select(:id))
        .joins('JOIN otu_scope os1 on os1.id = otu_relationships.subject_otu_id')

      b = OtuRelationship.with(otu_scope: otus.select(:id))
        .joins('JOIN otu_scope os1 on os1.id = otu_relationships.object_otu_id')

      c = ::Queries.union(OtuRelationship, [a,b])

      c.each do |orel|
        sources = orel.sources.load
        reference_ids = sources.collect{|a| a.id}
        reference_id = reference_ids.first

        csv << [
          orel.subject_otu_id,                                             # taxonID
          orel.object_otu_id,                                              # relatedTaxonID
          nil,                                                             # sourceID
          type(orel),                                                      # type
          reference_id,                                                    # referenceID
          nil,                                                             # remarks
          Export::Coldp.modified(orel[:updated_at]),                       # modified
          Export::Coldp.modified_by(orel[:updated_by_id], project_members) # modified_by
        ]

        Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv
      end
    end
  end
end
