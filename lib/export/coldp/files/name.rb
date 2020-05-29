# See
# * https://api.catalogue.life/vocab/rank
# * https://github.com/SpeciesFileGroup/taxonworks/issues/1040
module Export::Coldp::Files::Name

  # We don't cover ICNCP?
  def self.code_field(taxon_name)
    case taxon_name.nomenclatural_code
    when :iczn
      'ICZN'
    when :icn
      'ICN'
    when :icnp
      'ICNP'
    when :icvcn
      'ICVCN' # doublecheck
    end
  end

  def self.remarks_field(taxon_name)
    Utilities::Strings.nil_squish_strip(taxon_name.notes.collect{|n| n.text}.join('; ')) # remarks - !! check for tabs
  end

  def self.remarks_field(taxon_name)
    Utilities::Strings.nil_squish_strip(taxon_name.notes.collect{|n| n.text}.join('; ')) # remarks - !! check for tabs
  end

  # Not used in main loop, for reference only
  def published_in_id(taxon_name)
    taxon_name.source&.id
  end

  # @return Boolean
  #    true if original combination of the protonym

  def self.authorship_field(taxon_name, original)
    original ? taxon_name.original_author_year : taxon_name.cached_author_year
  end

  # @return [String, nil]
  # https://api.catalogue.life/vocab/nomStatus
  # Todo, move this to the concern
  #   https://github.com/SpeciesFileGroup/taxonworks/issues/1040
  def self.nom_status_field(taxon_name)
    case taxon_name.type
    when 'Combination'
      'chresonym'
    else
      nil
    end
  end

  # Is never a Combination, handles original combination
  def self.add_current_combination(t, csv)
    e = t.original_combination_elements
    csv << [
      ::Export::Coldp.current_taxon_name_id(t),                               # ID
      t.cached_original_combination,                                          # scientificName
      t.cached_author_year,                                                   # authorship
      t.rank,                                                                 # rank
      (e[:genus] =~ /NOT SPECIFIED/) ? nil : e[:genus]&.join(' '),            # genus
      (e[:subgenus] =~ /NOT SPECIFIED/) ? nil : e[:subgenus]&.join(' '),      # subgenus
      (e[:species] =~ /NOT SPECIFIED/) ? nil : e[:species]&.join(' '),        # species
      (e[:subspecies] =~ /NOT SPECIFIED/) ? nil : e[:subspecies]&.join(' '),  # subspecies
      nil,                                                                    # publishedInID   |
      nil,                                                                    # publishedInPage |-- Decisions is that these add to Synonym table
      nil,                                                                    # publishedInYear |
      false,                                                                  # original
      code_field(t),                                                          # code
      nil,                                                                    # status https://api.catalogue.life/vocab/nomStatus
      nil,                                                                    # link (probably TW public or API)
      remarks_field(t),                                                       # remarks
    ]
  end

  def self.generate(otu, reference_csv = nil)
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        ID
        scientificName
        authorship
        rank
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

      otu.taxon_name.self_and_descendants.each do |t|
        source = t.source # published_in_id_field

        original = Export::Coldp.original_field(t)

        csv << [
          t.id,                                      # ID
          t.cached,                                  # scientificName
          authorship_field(t, original),             # authorship
          t.rank,                                    # rank
          t.ancestor_at_rank('genus')&.cached,       # genus
          t.ancestor_at_rank('subgenus')&.cached,    # infragenericEpithet
          t.ancestor_at_rank('species')&.cached,     # specificEpithet
          t.ancestor_at_rank('subspecies')&.cached,  # infraspecificEpithet
          source&.id,                                # publishedInID
          source&.pages,                             # publishedInPage
          t.year_of_publication,                     # publishedInYear
          original,                                  # original
          code_field(t),                             # code
          nom_status_field(t),                       # nomStatus
          nil,                                       # link (probably TW public or API)
          remarks_field(t),                          # remarks
        ]

        add_current_combination(t, csv) if !original && !t.cached_original_combination.blank?

        Export::Coldp::Files::Reference.add_reference_rows([source].compact, reference_csv) if reference_csv
      end
    end
  end

end
