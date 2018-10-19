class NomenclaturalRank::Icnb::GenusGroup <  NomenclaturalRank::Icnb

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') if !taxon_name.name.blank? && taxon_name.name != taxon_name.name.capitalize && !taxon_name.name.include?(' ')
    taxon_name.errors.add(:name, 'name must be at least two letters') unless taxon_name.name.length > 1
  end

  def parent_rank
    nil
  end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icnb::FamilyGroup,
        NomenclaturalRank::Icnb::GenusGroup)
  end
end
