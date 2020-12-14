
# See https://github.com/Sp2000/coldp/blob/master/data/reference.tsv
module Export::Coldp::Files::Reference

  # This default method dumps the whole of project sources,
  # as an alternate way to generate the reference file.
  #
  # !! It is not integrated yet.
  # 
  def self.generate(project_id)
    CSV.generate do |csv|
      Source.joins(:project_sources).where(project_sources: {project_id: project_id} ).each do |source|
        csv << ref_row(source)
      end
    end
  end
    
  def self.add_reference_rows(sources = [], reference_csv)
    sources.each do |s|
      reference_csv[s.id] = ref_row(s)   
    end 
  end

  def self.ref_row(source)
    [
      source.id,
      source.cached,
#     source.cached_author_string,
#     source.year,
#     source.journal,                # source.source
#     reference_details(source),     # details (pages, volume, year)
      source.doi 
    ]
  end

  # TODO: this makes little sense without more structure, just spam stuff in until we understand more
  def self.reference_details(source)
    [source.volume, source.number, source.pages, source.bibtex_type].compact.join(';')
  end
  
end
