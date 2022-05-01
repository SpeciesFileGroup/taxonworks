class LoanRecipient < Role::ProjectRole
  has_many :loans, through: :loans, source: :recipient_person_id
  has_many :loaned_collection_objects, through: :loan_items, source: :collection_object

  def self.human_name
    'Loan recipient'
  end

  def year_active_year
    [ role_object.date_requested&.year,
      role_object.date_received&.year,
      #  role_object.date_closed&.year,  # post humous return
    ].compact.first
  end

end
