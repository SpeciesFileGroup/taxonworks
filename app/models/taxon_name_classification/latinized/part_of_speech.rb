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
      forms = t.predict_three_forms
      t.update_columns(
        masculine_name: forms[:masculine_name],
        feminine_name: forms[:feminine_name],
        neuter_name: forms[:neuter_name]
      )
    end
  end

  def validate_uniqueness_of_latinized
    if TaxonNameClassification::Latinized::PartOfSpeech.where(taxon_name_id: self.taxon_name_id).not_self(self).any?
      errors.add(:taxon_name_id, 'The Part of speech is already selected')
    end
  end
end
