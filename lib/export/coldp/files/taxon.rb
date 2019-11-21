#
# ID
# parentID
# nameID
# provisional
# accordingTo
# accordingToID
# accordingToDate
# referenceID
# fossil
# recent
# lifezone
# link
# remarks
#
module Export::Coldp::Files::Taxon

  # TODO: populate
  def self.references(otus)
    []
  end
  
  # return [Boolean, nil]
  #  TODO - reason in TW this is provision
  def self.provisional(otu)
    # nomen dubium
    # incertae sedis
    # unresolved homonym, without replacement
    #
    #    
    #
    # * if two OTUs for same name are in OTU set then both have to be provisional
    # * missaplication (?)
    nil 
  end

  # AttributionEditor
  #    * crawl attribution for inference on higher/lower 
  #    * UI/methods to assign/spam/visualize throught
  #    * project preference (!! should project preferences has reference ids? !!)
  # according to is the curator responsible for this OTU, comma delimited list of curators
  def self.according_to(otu)
    nil
  end

  #  ORCID only !!
  #  TODO: soft validation on Project ready for CoLDP
  def self.according_to_id(otu)
    nil
  end

  # Potentially reference 
  #    Confidence level 
  #       confidence_validated_at (last time this confidence level was deemed OK)
  def self.according_to_date(otu)
    # a) Dynamic - !! most recent update_at stamp for *any* OTU tied data -> this is a big grind: if so add cached_touched_on_date to Otu
    # b) modify Confidence level to include date
    # c) review what SFs does in their model 
    nil
  end

  # Predicates in TaxonWorks
  #   - make them default on Otu form
  #   - read in constants from API

  # default Predicates
  #   vs. calculated from CO
  def self.temporal_range_start(otu)
  end

  # default Predicates
  #   vs. calculated from CO
  def self.temporal_range_end(otu)
  end

  # @return [Boolean, nil]
  # Probably use default Predicate 'coldp_extinct'
  def self.extinct(otu)
  end

  # Derive from a default Predicate 
  #   when predicate created create URI to 
  #      http://api.col.plus/vocab/lifezone
  def self.lifezone(otu)
    # http://api.col.plus/vocab/lifezone
  end


  def self.link(otu)
   # API or public interface
  end

  # TODO: flag public
  def self.remarks(otu)
    otu.notes.pluck(:text).join('|')
  end

  # "supporting the taxonomic concept" 
  # Potentially- all other Citations tied to Otu, what exactly supports a concept?
  def self.reference_id(sources)
    i = sources.pluck(:id)
    return i.join(',') if i.any?
    nil
  end

  def self.generate(otus, reference_csv = nil )
    # TODO tabs delimit
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        ID
        parentID
        nameID
        provisional
        accordingTo
        accordingToID
        accordingToDate
        referenceID
        extinct
        temporalRangeStart
        temporalRangeEnd
        lifezone
        link
        remarks
      } 

      otus.each do |o|
        next unless o.taxon_name && o.taxon_name.is_valid?
        # TODO: Use Otu.coordinate_otus to summarize accros different instances
        sources = o.sources 
        
        csv << [
          o.id,                      # ID
          (o.parent_otu || nil)&.id, # parentID
          o.taxon_name&.id,          # nameID
          provisional(o),            # provisional
          according_to(o),           # accordingTo
          according_to_id(o),        # accordingToID
          according_to_date(o),      # accordingToDate
          reference_id(sources),     # referenceID
          extinct(o),                # extinct
          temporal_range_start(o),   # temporalRangeStart
          temporal_range_end(o),     # temporalRangeEnd
          lifezone(o),               # lifezone
          link(o),                   # link
          remarks(o)                 # remarks
        ]

        Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv
      end
    end
  end
end
