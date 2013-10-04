class NomenclaturalRank::Iczn::Governed::FamilyGroup::SuperfamilyGroup < NomenclaturalRank::Iczn::Governed::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::Ungoverned::SubinfraordinalGroup
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -oidea') if not(taxon_name.name =~ /.*oidea\Z/)
  end
end
