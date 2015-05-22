class Hybrid < Protonym

  soft_validate(:sv_hybrid_name_relationships, set: :hybrid_name_relationships)

  def get_full_name_html
    hr = self.hybrid_relationships(true)
    hr.empty? ? '[HYBRID TAXA NOT SELECTED]' : hr.collect{|i| i.subject_taxon_name.cached_html}.sort.join(' &#215; ')
  end

  def get_full_name
    hr = self.hybrid_relationships(true)
    hr.empty? ? '[HYBRID TAXA NOT SELECTED]' : hr.collect{|i| i.subject_taxon_name.cached}.sort.join(' x ')
  end

  def sv_hybrid_name_relationships
    case hybrid_relationships.count
      when 0
        soft_validations.add(:base, 'Hybrid is not linked to non hybrid taxa')
      when 1
        soft_validations.add(:base, 'Hybrid should be linked to at least two non hybrid taxa')
    end
  end


end
