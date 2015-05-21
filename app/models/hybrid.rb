class Hybrid < Protonym


  def get_full_name_html
    hr = self.hybrid_relationships
    hr.empty? ? '[HYBRID TAXA NOT SELECTED]' : hr.collect{|i| i.subject_taxon_name.cached_html}.sort.join(' &#215; ')

  end

end
