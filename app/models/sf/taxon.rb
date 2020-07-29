class SF::Taxon < SpeciesFileRecord
  self.table_name = 'tblTaxa'

  belongs_to :species_file, class_name: 'SF::SpeciesFile', foreign_key: 'FileID'

  belongs_to :rank, class_name: 'SF::Rank', foreign_key: 'RankID', inverse_of: :taxa
  belongs_to :parent, class_name: 'SF::Taxon', foreign_key: 'AboveID', optional: true
  belongs_to :like_name, class_name: 'SF::Taxon', foreign_key: 'LikeNameID', optional: true
  belongs_to :original_genus, class_name: 'SF::Taxon', foreign_key: 'OriginalGenusID', optional: true

  has_many :children, class_name: 'SF::Taxon', foreign_key: 'AboveID'
  has_many :citations, class_name: 'SF::Cite', foreign_key: 'TaxonNameID'

  belongs_to :creator, class_name: 'SF::FileUser', foreign_key: 'CreatedBy'
  belongs_to :updater, class_name: 'SF::FileUser', foreign_key: 'ModifiedBy'
end
