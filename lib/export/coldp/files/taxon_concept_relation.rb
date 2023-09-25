# taxonID
# relatedTaxonID
# sourceID
# type
# referenceID
# remarks
# modified
# modifiedBy
#
module Export::Coldp::Files::TaxonConceptRelation

    MAP_TYPES = {
        "OtuRelationship::Intersecting" => "intersecting",  # TODO: not included in CLB? http://api.checklistbank.org/vocab/TaxonConceptRelType
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
      Current.project_id = otus[0].project_id
      CSV.generate(col_sep: "\t") do |csv|
  
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
  
        OtuRelationship.where(project_id: Current.project_id).each do |orel|
  
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
  