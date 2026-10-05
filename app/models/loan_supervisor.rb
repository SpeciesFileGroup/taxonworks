class LoanSupervisor < Role::ProjectRole

  def self.human_name
    'Loan supervisor'
  end

  def year_active_year
    [ role_object.date_requested&.year,
      role_object.date_received&.year,
      #  role_object.date_closed&.year,  # post humous return
    ].compact.first
  end

end
