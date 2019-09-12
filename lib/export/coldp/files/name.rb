# remarks

# References
#   http://api.col.plus/vocab/rank
#
#  https://github.com/SpeciesFileGroup/taxonworks/issues/1040
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
    when :ictv 
      'ICVCN' # doublecheck
    end
  end

  def self.remarks_field(taxon_name)
    Utilities::Strings.nil_squish_strip(taxon_name.notes.collect{|n| n.text}.join('; ')) # remarks - !! check for tabs
  end

  def self.remarks_field(taxon_name)
    Utilities::Strings.nil_squish_strip(taxon_name.notes.collect{|n| n.text}.join('; ')) # remarks - !! check for tabs
  end

  def self.published_in_id_field(taxon_name)
    a = taxon_name.source&.id 
    # export_object.sources.push a # keep track of all the sources we need when we get to source tracking
    a
  end

  def self.generate(otu)
    CSV.generate do |csv|
      otu.taxon_name.descendants.each do |t|
        csv << [
          t.id,                                      # ID
          t.cached,                                  # scientificName
          t.cached_author_year,                      # authorship
          t.rank,                                    # rank 
          t.ancestor_at_rank('genus')&.cached,       # genus
          t.ancestor_at_rank('subgenus')&.cached,    # infragenericEpithet
          t.ancestor_at_rank('species')&.cached,     # specificEpithet 
          t.ancestor_at_rank('subspecies')&.cached,  # infraspecificEpithet
          published_in_id_field(t),                  # publishedInID
          t.source&.pages,                           # publishedInPage
          t.year_of_publication,                     # publishedInYear
          t.type == 'Protonym' ? true : false,       # original 
          code_field(t),                             # code 
          nil,                                       # status   http://api.col.plus/vocab/nomStatus
          nil,                                       # link (probably TW public or API)
          remarks_field(t),                                       # remarks
        ] 
      end
    end

  end
end

