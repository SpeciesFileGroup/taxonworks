class TaxonNameClassification::Latinized::Gender < TaxonNameClassification::Latinized

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000045'.freeze

  def self.applicable_ranks
    GENUS_RANK_NAMES
  end

  def validate_uniqueness_of_latinized
    if TaxonNameClassification::Latinized::Gender.where(taxon_name_id: self.taxon_name_id).not_self(self).any?
      errors.add(:taxon_name_id, 'The Gender is already selected')
    end
  end

  private

  def set_cached_names_for_taxon_names
    t = taxon_name
    t.update_column(:cached_gender, classification_label.downcase)

    t.descendants.unscope(:order).with_same_cached_valid_id.each do |t1|
      n = t1.get_full_name
      t1.update_columns(
        cached: n,
        cached_html: t1.get_full_name_html(n)
      )
    end

    TaxonNameRelationship::OriginalCombination.where(subject_taxon_name: t).collect{|i| i.object_taxon_name}.uniq.each do |t1|
      t1.update_cached_original_combinations
    end

    TaxonNameRelationship::Combination.where(subject_taxon_name: t).collect{|i| i.object_taxon_name}.uniq.each do |t1|
      t1.update_column(:verbatim_name, t1.cached) if t1.verbatim_name.nil?
      n = t1.get_full_name
      t1.update_columns(
        cached: n,
        cached_html: t1.get_full_name_html(n)
      )
    end
  end

end
