class SF::AuthUser < SpeciesFileRecord
  self.table_name = 'tblAuthUsers'

  has_many :file_users, class_name: 'SF::FileUser', foreign_key: 'FileUserID', inverse_of: :auth_user

  belongs_to :creator, class_name: 'SF::FileUser', foreign_key: 'CreatedBy'
  belongs_to :updater, class_name: 'SF::FileUser', foreign_key: 'ModifiedBy'
end
