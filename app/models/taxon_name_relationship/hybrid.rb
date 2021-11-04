class TaxonNameRelationship::Hybrid < TaxonNameRelationship

  def self.nomenclatural_priority
    :reverse
  end

  # left_side
  def self.valid_subject_ranks
    ::ICN
  end

  # right_side
  def self.valid_object_ranks
    ::ICN
  end

  def self.disjoint_subject_classes
    ::ICZN +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished,
                                                 TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
                                                 TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def self.assignable
    true
  end

  def self.disjoint_object_classes
    ::ICZN + ['TaxonNameClassification::Icn::Hybrid']
  end

  def sv_coordinated_taxa
    true # not applicable
  end

  def sv_coordinated_taxa_object
    true # not applicable
  end

  protected

  def set_cached_names_for_taxon_names
    begin
      TaxonName.transaction do
        t = object_taxon_name
        n = t.get_full_name
        t.update_columns(
          cached: n,
          cached_html: t.get_full_name_html(n)
        )
      end
    end
    true
  end

end