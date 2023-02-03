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
    extinct: 'https://api.checklistbank.org/datapackage#Taxon.extinct',                         # 1,0
    temporal_range_end: 'https://api.checklistbank.org/datapackage#Taxon.temporal_range_end',   # from https://api.checklistbank.org/vocab/geotime
    temporal_range_start: 'https://api.checklistbank.org/datapackage#Taxon.temporal_range_end', # from https://api.checklistbank.org/vocab/geotime
    lifezone: 'https://api.checklistbank.org/datapackage#Taxon.lifezone',                       # from https://api.checklistbank.org/vocab/lifezone
  }

  SKIPPED_RANKS = %w{
    NomenclaturalRank::Iczn::SpeciesGroup::Superspecies
    NomenclaturalRank::Iczn::SpeciesGroup::Supersuperspecies
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


  # Name phrase is for appended phrases like senso stricto and senso lato
  def self.name_phrase(otu, vocab_id)
    da = DataAttribute.find_by(type: 'InternalAttribute',
                               controlled_vocabulary_term_id: vocab_id,
                               attribute_subject_id: otu.id)
    da&.value
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

  def self.remarks(otu, taxon_remarks_vocab)
    if otu.data_attributes.where(controlled_vocabulary_term_id: taxon_remarks_vocab).any?
      otu.data_attributes.where(controlled_vocabulary_term_id: taxon_remarks_vocab).pluck(:value).join('|')
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

  def self.generate(otus, root_otu_id = nil, reference_csv = nil, prefer_unlabelled_otus: true)

    # Until we have RC5 articulations we are simplifying handling the fact
    # that one taxon name can be used for many OTUs. Track to see that
    # an OTU with a given taxon name does not already exist
    #   `taxon_name_id: nil`  - uniquify via Ruby hash keys
    observed_taxon_name_ids = { }

    # TODO: optional Taxon.alternativeID field allows inclusion of external identifiers: https://github.com/CatalogueOfLife/coldp#alternativeid-1 https://github.com/CatalogueOfLife/coldp#identifiers
    #   e.g., gbif:2704179,col:6W3C4,BOLD:AAJ2287,wikidata:Q157571

    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        ID
        parentID
        nameID
        namePhrase
        provisional
        accordingToID
        scrutinizer
        scrutinizerID
        scrutinizerDate
        referenceID
        extinct
        temporalRangeStart
        temporalRangeEnd
        environment
        link
        remarks
      }

      taxon_remarks_vocab_id = Predicate.find_by(uri: 'https://github.com/catalogueoflife/coldp#Taxon.remarks',
                                                 project_id: otus[0]&.project_id)&.id
      otus.each do |o|
        # !! When a name is a synonmy (combination), but that combination has no OTU
        # !! then the parent of the name in the taxon table is nil
        # !! Handle this edge case (probably resolved now)

        # TODO: alter way parent is set to conform to CoLDP status
        #   For OTUs with combinations we might have to change the parenthood?!

        parent_id = nil
        if root_otu_id != o.id
          if pid = o.parent_otu_id(skip_ranks: SKIPPED_RANKS, prefer_unlabelled_otus: prefer_unlabelled_otus)
            parent_id = pid
          else
            puts 'WARNING no parent!!'
            # there is no OTU parent for the hierarchy, at present we just flat skip this OTU
            # Curators can use the create OTUs for valid ids to resolve this data issue
            next
          end
        end

        # TODO: This was excluding OTUs that were being excluded downstream previously
        # This should never happen now since parent ambiguity is caught above!
        # can be removed in theory
        # TODO: remove once RC5 better modelled
        next if observed_taxon_name_ids[o.taxon_name_id]
        observed_taxon_name_ids[o.taxon_name_id] = nil

        # TODO: Use o.coordinate_otus to summarize accross different instances of the OTU

        sources = o.sources
        source = o.source

        parent_id = (root_otu_id == o.id ? nil : parent_id )

        csv << [
          o.id,                                              # ID (Taxon)
          parent_id,                                         # parentID (Taxon)
          o.taxon_name.id,                                   # nameID (Name)
          name_phrase(o, name_phrase_vocab_id),              # namePhrase
          provisional(o),                                    # provisional
          according_to_id(o),                                # accordingToID
          scrutinizer(o),                                    # scrutinizer
          scrutinizer_id(o),                                 # scrutinizerID
          scrutinizer_date(o),                               # scrutizinerDate
          reference_id(sources),                             # referenceID
          predicate_value(o, :extinct),              # extinct
          predicate_value(o, :temporal_range_start), # temporalRangeStart
          predicate_value(o, :temporal_range_end),   # temporalRangeEnd
          predicate_value(o, :lifezone),             # environment (formerly named lifezone)
          link(o),                                   # link
          remarks(o, taxon_remarks_vocab_id)         # remarks
        ]

        Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv
      end
    end
  end
end
