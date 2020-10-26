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
      'chresonym'
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
  # @param t [An invalid Protonym]
  #    only place that var./frm can be handled.
  def self.add_original_combination(t, csv)
    e = t.original_combination_elements

    infraspecific_epithet = [
      e[:form], e[:variety], e[:subspecies]
    ].compact&.first&.last

    csv << [
      ::Export::Coldp.reified_id(t),                                          # ID
      t.id,                                                                   # basionymID, always nil, this is the original
      t.cached_original_combination,                                          # scientificName
      authorship_field(t, true),                                              # authorship
      t.rank,                                                                 # rank
      nil,                                                                    # uninomial
      (e[:genus] =~ /NOT SPECIFIED/) ? nil : e[:genus]&.last,                 # genus
      (e[:subgenus] =~ /NOT SPECIFIED/) ? nil : e[:subgenus]&.last,           # subgenus (no parens)
      (e[:species] =~ /NOT SPECIFIED/) ? nil : e[:species]&.last,             # species
      infraspecific_epithet,                                                  # infraspecificEpithet
      nil,                                                                    # publishedInID   |
      nil,                                                                    # publishedInPage |-- Decisions is that these add to Synonym table
      nil,                                                                    # publishedInYear |
      true,                                                                   # original
      code_field(t),                                                          # code
      nil,                                                                    # status https://api.catalogue.life/vocab/nomStatus
      nil,                                                                    # link (probably TW public or API)
      remarks_field(t),                                                       # remarks
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

            original = Export::Coldp.original_field(t) # no parens
            higher = !(t.type == 'Combination') && !t.is_species_rank?

            if higher || t.is_valid? || t.is_combination?
              csv << [
                t.id,                                                          # ID
                (original ? nil : ::Export::Coldp.basionym_id(t)),             # basionymID
                t.cached,                                                      # scientificName
                t.cached_author_year,                                          # authorship
                t.rank,                                                        # rank
                (higher ? t.cached : nil),                                     # uninomial
                (higher ? nil : t.ancestor_at_rank('genus', true)&.name),      # genus and below - IIF species or lower
                (higher ? nil : t.ancestor_at_rank('subgenus', true)&.name),   # infragenericEpithet
                (higher ? nil : t.ancestor_at_rank('species', true)&.name),    # specificEpithet
                (higher ? nil : t.ancestor_at_rank('subspecies', true)&.name), # infraspecificEpithet
                source&.id,                                                    # publishedInID
                source&.pages,                                                 # publishedInPage
                t.year_of_publication,                                         # publishedInYear
                original,                                                      # original
                code_field(t),                                                 # code
                nom_status_field(t),                                           # nomStatus
                nil,                                                           # link (probably TW public or API)
                remarks_field(t),                                              # remarks
              ]
            end

            if !higher && !t.is_combination?
              add_original_combination(t, csv)
            end

            Export::Coldp::Files::Reference.add_reference_rows([source].compact, reference_csv) if reference_csv && source
          end
        end
      end
    end
  end

end
