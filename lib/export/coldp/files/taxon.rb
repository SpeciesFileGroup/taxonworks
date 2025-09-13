# Concepts not mapped:
#    `namePhrase` - e.g. `sensu lato` this would come from OTU#name
#
# Notes
#
# * ColDP importer has a normalizing step that recognizes some names no longer point to any OTU
# * CoLDP can not handle assertions that a name that is currently treated as (invalid) was useds as a name (valid) for previously valid concept, i.e. CoL does not track alternative past concept heirarchies
#
module Export::Coldp::Files::Taxon

  IRI_MAP = {
    extinct: 'https://api.checklistbank.org/datapackage#Taxon.extinct',                         # 1,0
    temporal_range_end: 'https://api.checklistbank.org/datapackage#Taxon.temporal_range_end',   # from https://api.checklistbank.org/vocab/geotime
    temporal_range_start: 'https://api.checklistbank.org/datapackage#Taxon.temporal_range_end', # from https://api.checklistbank.org/vocab/geotime
    lifezone: 'https://api.checklistbank.org/datapackage#Taxon.lifezone',                       # from https://api.checklistbank.org/vocab/lifezone
    remarks: 'https://github.com/catalogueoflife/coldp#Taxon.remarks',
    namePhrase: 'https://github.com/catalogueoflife/coldp#Taxon.namePhrase',
    link: 'https://api.checklistbank.org/vocab/term/col:link'
  }.freeze

  SKIPPED_RANKS = %w{
    NomenclaturalRank::Iczn::SpeciesGroup::Superspecies
    NomenclaturalRank::Iczn::SpeciesGroup::Supersuperspecies
  }.freeze

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

  # TODO: this will be lookups on Confidence loaded into memory
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
    # a) Dynamic - !! most recent updated_at stamp for *any* OTU tied data -> this is a big grind: if so add cached_touched_on_date to Otu
    # b) modify Confidence level to include date
    # c) review what SFs does in their model
    nil
  end

  def self.link(link_base_url, otu)
    link_base_url&.gsub('{id}', otu.id.to_s) unless link_base_url.nil?
  end

  def self.remarks(otu, taxon_remarks_vocab_id)
    if !taxon_remarks_vocab_id.nil? && otu.data_attributes.where(controlled_vocabulary_term_id: taxon_remarks_vocab_id).any?
      otu.data_attributes.where(controlled_vocabulary_term_id: taxon_remarks_vocab_id).pluck(:value).join('|')
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

  def self.attributes(otus, target)
    a = DataAttribute.with(otu_scope: otus)
      .joins("JOIN otu_scope on data_attributes.attribute_subject_id = otu_scope.id AND data_attributes.attribute_subject_type = 'Otu'")
      .joins(:predicate)
      .select("data_attributes.attribute_subject_id, STRING_AGG(data_attributes.value::text, ',') AS #{target}")
      .where(predicate: { uri: IRI_MAP[target] })
      .group('data_attributes.attribute_subject_id')
      .map{|a| [a.id, a.send(target)]}.to_h
  end

  def self.generate(otu, otus, project_members, reference_csv = nil, prefer_unlabelled_otus = true)

    # Until we have RC5 articulations we are simplifying handling the fact
    # that one taxon name can be used for many OTUs. Track to see that
    # an OTU with a given taxon name does not already exist
    #   `taxon_name_id: nil`  - unify via Ruby hash keys
    observed_taxon_name_ids = { }

    # TODO: optional Taxon.alternativeID field allows inclusion of external identifiers: https://github.com/CatalogueOfLife/coldp#alternativeid-1 https://github.com/CatalogueOfLife/coldp#identifiers
    #   e.g., gbif:2704179,col:6W3C4,BOLD:AAJ2287,wikidata:Q157571

    targets = otus
      .left_joins(:sources)
      .select("otus.*, STRING_AGG(sources.id::text, ',') AS aggregate_source_ids")
      .left_joins(:taxon_name)
      .where("taxon_names.cached NOT LIKE '%SPECIFIED%'") # TODO: likley not doing what we think it is
      .group('otus.id')

    attributes = {}

    # Make one big lookup
    IRI_MAP.each do |k,v|
      attributes[k] = attributes(otus, k)
    end

    link_base_url = attributes[:link][otu.id]
    root_otu_id = otu.id

    parent_id_lookup = Otu.parent_otu_ids(otus, skip_ranks: SKIPPED_RANKS).map{|a| [a.id, a.valid_ancestor_otu_ids&.split(',')&.first&.to_i]}.to_h

    text =  ::CSV.generate(col_sep: "\t") do |csv|

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
        modified
        modifiedBy
      }

      targets.find_each do |o|

        parent_id = parent_id_lookup[o.id]
        parent_id = (root_otu_id == o.id ? nil : parent_id )

        # TODO: This was excluding OTUs that were being excluded downstream previously
        # This should never happen now since parent ambiguity is caught above!
        # can be removed in theory
        # TODO: remove once RC5 better modelled
        next if observed_taxon_name_ids[o.taxon_name_id]
        observed_taxon_name_ids[o.taxon_name_id] = nil

        # TODO: NOT SPECIFIED is left out no from Name, but not populating a tracking list
        #
        # If this is required add it to the `target` scope above
        # some names are skipped (e.g., if they have NOT SPECIFIED names)

        csv << [
          o.id,                                                            # ID (Taxon)
          parent_id,                                                       # parentID (Taxon)
          o.taxon_name_id,                                                 # nameID (Name)
          attributes[:namePhrase][o.id],                                   # namePhrase
          nil,                                                             # provisional provisional(o)
          nil,                                                             # accordingToID according_to_id(o)
          nil,                                                             # scrutinizer scrutinizer(o)
          nil,                                                             # scrutinizerID scrutinizer_id(o)
          nil,                                                             # scrutizinerDate scrutinizer_date(o)
          o.aggregate_source_ids,                                          # referenceID
          attributes[:extinct][o.id],                                      # extinct
          attributes[:temporal_range_start][o.id],                         # temporalRangeStart
          attributes[:temporal_range_end][o.id],                           # temporalRangeEnd
          attributes[:lifezone][o.id],                                     # environment (formerly named lifezone)
          link(link_base_url, o),                                          # link
          Export::Coldp.sanitize_remarks(attributes[:remarks][o.id]),      # remarks
          Export::Coldp.modified(o[:updated_at]),                          # modified
          Export::Coldp.modified_by(o[:updated_by_id], project_members)    # modifiedBy
        ]

      end
    end

    sources = Source.with(name_scope: targets.unscope(:select).select(:id))
      .joins(:citations)
      .joins("JOIN name_scope ns on ns.id = citations.citation_object_id AND citations.citation_object_type = 'Otu'")
      .distinct

    Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv
    text
  end
end
