class SF::SpeciesFile < SpeciesFileRecord
  self.table_name = 'tblFiles'

  belongs_to :parent, class_name: 'SF::SpeciesFile', foreign_key: 'AboveID'

  belongs_to :creator, class_name: 'SF::FileUser', foreign_key: 'CreatedBy'
  belongs_to :updater, class_name: 'SF::FileUser', foreign_key: 'ModifiedBy'
end
