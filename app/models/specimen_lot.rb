class SpecimenLot < Specimen

  validate :total_must_be_greater_than_one

  protected

  def total_must_be_greater_than_one
    errors.add(:total, "total is not > 1, or nil") if total && not(self.total > 1)
  end


end
