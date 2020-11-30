module Export::Coldp::Files::Name

  def self.code_field(taxon_name)
    case taxon_name.nomenclatural_code
    when :iczn
      'ICZN'
    when :icn
      'ICN'
    when :icnp
      'ICNP'
    when :icvcn
      'ICVCN'
    end
  end

  def self.remarks_field(taxon_name)
    Utilities::Strings.nil_squish_strip(taxon_name.notes.collect{|n| n.text}.join('; ')) # remarks - !! check for tabs
  end

  # @return String
  def self.authorship_field(taxon_name, original)
    original ? taxon_name.original_author_year : taxon_name.cached_author_year
  end

  # https://api.catalogue.life/vocab/nomStatus
  # @return [String, nil]
  # @params taxon_name [TaxonName]
  #   any TaxonName
  def self.nom_status_field(taxon_name)
    case taxon_name.type
    when 'Combination'
      'chresonym' # TODO: remove this for updated semantics
    else
      if taxon_name.is_valid?
        ::TaxonName::NOMEN_VALID[taxon_name.nomenclatural_code]
      else
        c = taxon_name.taxon_name_classifications_for_statuses.order_by_youngest_source_first.first
        c ? c.class::NOMEN_URI : nil # We should also infer status from TaxonNameRelationship see
      end
    end
  end

  # Invalid Protonyms are rendered only as their original Combination
  # @param t [Protonym]
  #    only place that var./frm can be handled.
  def self.add_original_combination(t, csv)
    e = t.original_combination_elements

    infraspecific_element = t.original_combination_infraspecific_element(e)
    rank = infraspecific_element ? infraspecific_element.first : t.rank

    id = t.reified_id

    csv << [
      id,                                                                                     # ID
      id,                                                                                     # basionymID, always nil, this is the original
      t.cached_original_combination,                                                          # scientificName
      authorship_field(t, true),                                                              # authorship
      rank,                                                                                   # rank
      nil,                                                                                    # uninomial
      (e[:genus]&.last =~ /NOT SPECIFIED/) ? nil : e[:genus]&.last,                           # genus
      (e[:subgenus]&.last =~ /NOT SPECIFIED/) ? nil : e[:subgenus]&.last&.gsub(/[\)\(]/, ''), # subgenus (no parens) # TODO - optimize to not have to strip these
      (e[:species]&.last =~ /NOT SPECIFIED/) ? nil : e[:species]&.last,                       # species
      infraspecific_element ? infraspecific_element.last : nil,                           # infraspecificEpithet
      nil,                                                                                # publishedInID   |
      nil,                                                                                # publishedInPage |-- Decisions is that these add to Synonym table
      nil,                                                                                # publishedInYear |
      true,                                                                               # original
      code_field(t),                                                                      # code
      nil,                                                                                # status https://api.catalogue.life/vocab/nomStatus
      nil,                                                                                # link (probably TW public or API)
      remarks_field(t),                                                                   # remarks
    ]
  end

  # @params otu [Otu]
  #   the top level OTU
  def self.generate(otu, reference_csv = nil)
    CSV.generate(col_sep: "\t") do |csv|
      csv << %w{
        ID
        basionymID
        scientificName
        authorship
        rank
        uninomial
        genus
        infragenericEpithet
        specificEpithet
        infraspecificEpithet
        publishedInID
        publishedInPage
        publishedInYear
        original
        code
        status
        link
        remarks
      }

      # why we getting double
      unique = {}

      otu.taxon_name.self_and_descendants.each do |name|

        # TODO: handle > quadranomial names (e.g. super species like `Bus (Dus aus aus) aus eus var. fus`
        # Proposal is to exclude names of a specific ranks see taxon.rb
        #
        # Need the next highest valid parent not in this list!!
        # %w{
        #   NomenclaturalRank::Iczn::SpeciesGroup::Supersuperspecies
        #   NomenclaturalRank::Iczn::SpeciesGroup::Superspecies
        # }
        #
        # infragenericEpithet needs to handle subsection (NomenclaturalRank::Icn::GenusGroup::Subsection)

        if name.is_valid?
          data = ::Catalog::Nomenclature::Entry.new(name)

          data.names.each do |t|
            source = t.source

            original = Export::Coldp.original_field(t) # Protonym, no parens
            higher = !t.is_combination? && !t.is_species_rank?

            elements = t.full_name_hash if !higher

            basionym_id = t.reified_id

            # higher, valid, combination and not added
            if higher || t.is_valid? || t.is_combination? # && unique[basionym_id].nil?
              # unique[basionym_id] = true
              csv << [
                t.id,                                               # ID
                basionym_id,                                        # basionymID
                t.cached,                                           # scientificName
                t.cached_author_year,                               # authorship
                t.rank,                                             # rank
                (higher ? t.cached : nil),                          # uninomial
                (higher ? nil : elements['genus']&.last),           # genus and below - IIF species or lower
                (higher ? nil : elements['subgenus']&.last),        # infragenericEpithet
                (higher ? nil : elements['species']&.last),         # specificEpithet
                (higher ? nil : elements['subspecies']&.last),      # infraspecificEpithet
                source&.id,                                         # publishedInID
                source&.pages,                                      # publishedInPage
                t.year_of_publication,                              # publishedInYear
                original,                                           # original
                code_field(t),                                      # code
                nom_status_field(t),                                # nomStatus
                nil,                                                # link (probably TW public or API)
                remarks_field(t),                                   # remarks
              ]
            end

            if (!higher && !t.is_combination? && (!t.is_valid? || t.has_alternate_original?)) && unique[basionym_id].nil?
              unique[basionym_id] = true
              add_original_combination(t, csv)
            end

            Export::Coldp::Files::Reference.add_reference_rows([source].compact, reference_csv) if reference_csv && source
          end
        end
      end
    end
  end

end
