class SF::Cite < SpeciesFileRecord
  self.table_name = 'tblCites'

  default_scope { order(:TaxonNameID, :SeqNum) } # NOTE: overrides has_many relation in SF::Taxon which only orders by :SeqNum (no conflict).

  belongs_to :taxon, class_name: 'SF::Taxon', foreign_key: 'TaxonNameID'
  belongs_to :nomenclator, class_name: 'SF::Nomenclator', foreign_key: 'NomenclatorID', optional: true

  belongs_to :creator, class_name: 'SF::FileUser', foreign_key: 'CreatedBy'
  belongs_to :updater, class_name: 'SF::FileUser', foreign_key: 'ModifiedBy'
end
