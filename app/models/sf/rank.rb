class SF::Rank < SpeciesFileRecord
  self.table_name = 'tblRanks'

  has_many :taxa, class_name: 'SF::Taxon', foreign_key: 'RankID', inverse_of: :rank
end
