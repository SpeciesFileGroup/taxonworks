class NomenclaturalRank::Icnp::FamilyGroup::Family < NomenclaturalRank::Icnp::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::HigherClassificationGroup::Suborder
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -aceae') if not(taxon_name.name =~ /.*(aceae|Compositae|Cruciferae|Gramineae|Guttiferae|Labiatae|Leguminosae|Palmae|Umbelliferae)\Z/)
  end

  def self.valid_name_ending
    'aceae'
  end

  def self.abbreviation
    'fam.'
  end
end
