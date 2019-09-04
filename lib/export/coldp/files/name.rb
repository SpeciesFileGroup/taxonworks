module Export::Coldp::Files::Name
  def self.generate(otu)
    CSV.generate do |csv|
      otu.taxon_name.descendants.each do |t|
        csv << [
          t.id, 
          t.cached,
          t.cached_author_year,
          t.rank,  #  http://api.col.plus/vocab/rank
          t.ancestor_at_rank('genus')&.cached,
          t.ancestor_at_rank('subgenus')&.cached,
          t.ancestor_at_rank('subspecies')&.cached,
          t.citations.pluck(:source_id),
          t.source.pages,
          t.year_of_publication,
          t.type == 'Protonym' ? true : false,
          t.nomenclatural_code,                                                       # will turn into `.coldb_code` 
          nil,                                                                        # status - http://api.col.plus/vocab/nomStatus
          nil,                                                                        # link - link to anchored TaxonWorks public;  anchor
          Utilities::Strings.nil_squish_strip(t.notes.collect{|n| n.text}.join('; ')) # remarks - !! check for tabs
        ] 
      end
    end
  end
end

