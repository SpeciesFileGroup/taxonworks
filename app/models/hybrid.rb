class Hybrid < Protonym

  def get_full_name_html
    hr = self.hybrid_relationships(true)
    hr.empty? ? '[HYBRID TAXA NOT SELECTED]' : hr.collect{|i| i.subject_taxon_name.cached_html}.sort.join(' &#215; ')
  end

  def get_full_name
    hr = self.hybrid_relationships(true)
    hr.empty? ? '[HYBRID TAXA NOT SELECTED]' : hr.collect{|i| i.subject_taxon_name.cached}.sort.join(' x ')
  end

end
