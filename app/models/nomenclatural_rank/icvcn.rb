class NomenclaturalRank::Icvcn < NomenclaturalRank

  def self.group_base(rank_string)
    rank_string.match( /(NomenclaturalRank::Icvcn::).+/)
    $1
  end

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'name must be at least two letters') unless taxon_name.name.length > 1
  end

end