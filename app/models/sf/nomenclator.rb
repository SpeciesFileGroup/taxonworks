class SF::Nomenclator < SpeciesFileRecord
  self.table_name = 'tblNomenclator'

  belongs_to :species_file, class_name: 'SF::SpeciesFile', foreign_key: 'FileID'

  belongs_to :genus_name, class_name: 'SF::GenusName', foreign_key: 'GenusNameID', optional: true
  belongs_to :subgenus_name, class_name: 'SF::GenusName', foreign_key: 'SubgenusNameID', optional: true
  belongs_to :infragenus_name, class_name: 'SF::GenusName', foreign_key: 'InfragenusNameID', optional: true

  belongs_to :species_series_name, class_name: 'SF::SpeciesName', foreign_key: 'SpeciesSeriesNameID', optional: true
  belongs_to :species_group_name, class_name: 'SF::SpeciesName', foreign_key: 'SpeciesGroupNameID', optional: true
  belongs_to :species_subgroup_name, class_name: 'SF::SpeciesName', foreign_key: 'SpeciesSubgroupNameID', optional: true
  belongs_to :species_name, class_name: 'SF::SpeciesName', foreign_key: 'SpeciesNameID', optional: true
  belongs_to :subspecies_name, class_name: 'SF::SpeciesName', foreign_key: 'SubspeciesNameID', optional: true
  belongs_to :infrasubspecies_name, class_name: 'SF::SpeciesName', foreign_key: 'InfrasubspeciesNameID', optional: true

  belongs_to :creator, class_name: 'SF::FileUser', foreign_key: 'CreatedBy'
  belongs_to :updater, class_name: 'SF::FileUser', foreign_key: 'ModifiedBy'
end
