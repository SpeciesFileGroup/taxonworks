# taxonID
# relatedTaxonID
# relatedTaxonScientificName
# type
# referenceID
# remarks
#
module Export::Coldp::Files::SpeciesInteraction

  def self.taxon_id(ba)
    subject_otu = nil
    if ba.biological_association_subject_type == "Otu"
      begin
        subject_otu = Otu.find(ba.biological_association_subject_id).id
      rescue ActiveRecord::RecordNotFound
        subject_otu = nil
      end
    end
    subject_otu
  end

  def self.related_taxon_id(ba)
    object_otu = nil
    if ba.biological_association_object_type == "Otu"
      begin
        object_otu = Otu.find(ba.biological_association_object_id).id
      rescue ActiveRecord::RecordNotFound
        object_otu = nil
      end
    end
    object_otu
  end

  def self.related_taxon_scientific_name(otu_id)
    object_taxon_name = nil
    begin
      o = Otu.find(otu_id)
    rescue ActiveRecord::RecordNotFound
      return nil
    end
    if !o.taxon_name_id.nil?
      object_taxon_name = TaxonName.find(o.taxon_name_id).cached
    else
      unless o.name.nil?
        object_taxon_name = o.name
      end
    end
    object_taxon_name
  end

  def self.species_interaction_type(ba, inverted=false)
    species_interaction_type = BiologicalRelationship.find(ba.biological_relationship_id).name
    if inverted
      species_interaction_type = BiologicalRelationship.find(ba.biological_relationship_id).inverted_name
    end
    species_interaction_type
  end

  def self.generate(otus, reference_csv = nil )
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        taxonID
        relatedTaxonID
        relatedTaxonScientificName
        type
        referenceID
        remarks
      }

      otus.joins(:biological_associations).where("biological_associations.biological_association_subject_type = 'Otu' and biological_associations.biological_association_object_type = 'Otu'").distinct.each do |o|
        o.biological_associations.each do |ba|

          taxon_id = taxon_id(ba)
          related_taxon_id = related_taxon_id(ba)
          sources = ba.sources.load
          reference_ids = sources.collect{|a| a.id}
          reference_id = reference_ids.first

          csv << [
            taxon_id,                                                 # taxonID
            related_taxon_id,                                         # relatedTaxonID
            related_taxon_scientific_name(related_taxon_id),          # relatedTaxonScientificName
            species_interaction_type(ba),                             # type
            reference_id,                                             # referenceID
            nil,                                                      # remarks
          ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv
        end
      end
    end
  end
end

