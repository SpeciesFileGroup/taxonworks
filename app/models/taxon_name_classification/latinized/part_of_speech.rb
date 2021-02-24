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
      m_name, f_name, n_name = nil, nil, nil

      case t.name
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
        m_name, f_name, n_name = t.name[0..-4] + 'er', t.name, t.name[0..-2] + 'um'
      when /a$/
        m_name, f_name, n_name = t.name[0..-2] + 'us', t.name, t.name[0..-2] + 'um'
      when /or$/
        # TODO: Move check for names ending in `or` to soft valdiation vs. Partciple/Adjective (combination shouldn't exist) 
      else
        m_name, f_name, n_name = t.name, t.name, t.name
      end

      t.update_columns(
        masculine_name: m_name,
        feminine_name: f_name,
        neuter_name: n_name
      )
    end
  end

  def validate_uniqueness_of_latinized
    if TaxonNameClassification::Latinized::PartOfSpeech.where(taxon_name_id: self.taxon_name_id).not_self(self).any?
      errors.add(:taxon_name_id, 'The Part of speech is already selected')
    end
  end
end
