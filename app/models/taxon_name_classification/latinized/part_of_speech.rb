class TaxonNameClassification::Latinized::PartOfSpeech < TaxonNameClassification::Latinized

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000046'.freeze

  def self.applicable_ranks
    SPECIES_RANK_NAMES
  end

  protected

  # A set_cached helper, see Participle, Adjective
  def set_gender_in_taxon_name
    t = taxon_name
    if t.masculine_name.blank? && t.feminine_name.blank? && t.neuter_name.blank?
      n = t.name
      m_name, f_name, n_name = nil, nil, nil

      case n
      when /is$/
        m_name, f_name, n_name = t.name, t.name, t.name[0..-3] + 'e'
      when /e$/
        m_name, f_name, n_name = t.name[0..-2] + 'is', t.name[0..-2] + 'is', t.name
      when /us$/
        m_name, f_name, n_name = t.name, t.name[0..-3] + 'a', t.name[0..-3] + 'um'
      when /er$/
        m_name, f_name, n_name = t.name, t.name[0..-3] + 'ra', t.name[0..-3] + 'rum'
      when /(um|rum)$/
        m_name, f_name, n_name = t.name[0..-3] + 'us', t.name[0..-3] + 'a', t.name
      when /ra$/
        m_name, f_name, n_name = t.name[0..-3] + 'er', t.name, t.name[0..-3] + 'rum'
      when /a$/
        m_name, f_name, n_name = t.name[0..-2] + 'us', t.name, t.name[0..-2] + 'um'
      when /or$/
        # TODO: Move check for names ending in `or` to soft valdiation vs. Partciple/Adjective (combination shouldn't exist) 
      else
      end

      t.update_columns(
        masculine_name: m_name,
        feminine_name: f_name,
        neuter_name: n_name
      )
    end
  end



end
