class SF::FileUser < SpeciesFileRecord
  self.table_name = 'tblFileUsers'

  belongs_to :species_file, class_name: 'SF::SpeciesFile', foreign_key: 'FileID'

  belongs_to :auth_user, class_name: 'SF::AuthUser', foreign_key: 'AuthUserID', inverse_of: :file_users

  belongs_to :creator, class_name: 'SF::FileUser', foreign_key: 'CreatedBy'
end
