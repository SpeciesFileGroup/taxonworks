# Concepts not mapped:
#    `namePhrase` - e.g. `sensu lato` this would come from OTU#name
#
# Notes
#
# * ColDP importer has a normalizing step that recognizes some names no longer point to any OTU
# * CoLDP can not handle assertions that a name that is currently treated as (invalid) was useds as a name (valid) for previously valid concept, i.e. CoL does not track alternative past concept heirarchies
#
# TODO: create map of all possible CoLDP used IRIs and ability to populate project with them automatically
#
module Export::Coldp::Files::Taxon

  IRI_MAP = {
    extinct: 'https://api.catalogue.life/datapackage#Taxon.extinct',                         # 1,0
    temporal_range_end: 'https://api.catalogue.life/datapackage#Taxon.temporal_range_end',   # from https://api.catalogue.life/vocab/geotime
    temporal_range_start: 'https://api.catalogue.life/datapackage#Taxon.temporal_range_end', # from https://api.catalogue.life/vocab/geotime
    lifezone: 'https://api.catalogue.life/datapackage#Taxon.lifezone',                       # from https://api.catalogue.life/vocab/lifezone
  }

  # @param predicate [:symbol]
  #   a key from IRI_MAP
  def self.predicate_value(otu, predicate)
    return nil unless IRI_MAP[predicate]
    otu.data_attributes.joins(:predicate).where(controlled_vocabulary_terms: {uri: IRI_MAP[predicate]}).first&.value
  end

  # return [Boolean, nil]
  #  TODO - reason in TW this is provisional name
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

  # The scrutinizer concept is unused at present
  # We're looking for the canonical implementation of it
  # before we implement/extrapolate from data here.
  #    * crawl attribution for inference on higher/lower
  #    * UI/methods to assign/spam/visualize throught
  #    * project preference (!! should project preferences has reference ids? !!)
  # according to is the curator responsible for this OTU, comma delimited list of curators
  # We could also look at time-stamp data to detect "staleness" of an OTU concept
  def self.scrutinizer(otu)
    nil
  end

  # ORCID version of above
  def self.scrutinizer_id(otu)
    nil
  end

  def self.scrutinizer_date(otu)
    nil
  end

  #  A reference to the publication of the person who established the taxonomic concept
  #     TW has a plurality of sources that reference this concept, it's a straightforward map
  #     It is somewhat unclear how/whether CoL will use this concept
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

  def self.link(otu)
    # API or public interface
  end

  # TODO: flag/exclude ! is_public
  def self.remarks(otu)
    if otu.notes.load.any?
      otu.notes.pluck(:text).join('|')
    else
      nil
    end
  end

  # "supporting the taxonomic concept"
  # Potentially- all other Citations tied to Otu, what exactly supports a concept?
  def self.reference_id(sources)
    i = sources.pluck(:id)
    return i.join(',') if i.any?
    nil
  end

  def self.generate(otus, root_otu_id = nil, reference_csv = nil )

    # Until we have RC5 articulations we are temporarily glossing over the fact
    # that one taoxn name can be used for many OTUs.  Track to see that
    # an OTU with a given taxon name does not already exist
    #   taxon_name_id: otu_id (the value is not needed)
    observed_taxon_name_ids = { }

    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        ID
        parentID
        nameID
        provisional
        accordingToID
        scrutinizer
        scrutinizerID
        scrutinizerDate
        referenceID
        extinct
        temporalRangeStart
        temporalRangeEnd
        lifezone
        link
        remarks
      }

      otus.each do |o|
        next unless o.taxon_name_id && o.taxon_name.is_valid?

        # TODO: remove once RC5 better modelled
        next if observed_taxon_name_ids[o.taxon_name_id]

        observed_taxon_name_ids[o.taxon_name_id] = o.id

        # TODO: Use o.coordinate_otus to summarize accross different instances of the OTU

        sources = o.sources
        source = o.source

        # !! When a name is a synonmy (combination), but that combination has no OTU
        # !! then the parent of the name in the taxon table is nil
        # !! Handle this edge case

        # TODO: alter way parent is set to conform to CoLDP status
        # Consider:
        #    OTUs/ranks are excluded :
        # Need the next highest valid parent not in this list!!
        # %w{
        #   NomenclaturalRank::Iczn::SpeciesGroup::Supersuperspecies
        #   NomenclaturalRank::Iczn::SpeciesGroup::Superspecies
        # }
        #
        # Also:
        #   For OTUs with combinations we might have to change the parenthood?!

        parent_id = nil
        if root_otu_id != o.id
          if pid = o.parent_otu_id
            parent_id = pid
          else
            # there is no OTU parent for the hierarchy, at present we just flat skip this OTU
            # curators can use the create OTUs for valid ids to resolve this data issue
            next
          end
        end

        parent_id = (root_otu_id == o.id ? nil : parent_id )

        csv << [
          o.id,                                      # ID
          parent_id,                                 # parentID
          o.taxon_name&.id,                          # nameID
          provisional(o),                            # provisional
          according_to_id(o),                        # accordingToID
          scrutinizer(o),                            # scrutinizer
          scrutinizer_id(o),                         # scrutinizerID
          scrutinizer_date(o),                       # scrutizinerDate
          reference_id(sources),                     # referenceID
          predicate_value(o, :extinct),              # extinct
          predicate_value(o, :temporal_range_start), # temporalRangeStart
          predicate_value(o, :temporal_range_end),   # temporalRangeEnd
          predicate_value(o, :lifezone),             # lifezone
          link(o),                                   # link
          remarks(o)                                 # remarks
        ]

        Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv
      end
    end
  end
end
