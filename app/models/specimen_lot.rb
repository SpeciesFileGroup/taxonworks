class SpecimenLot < PhysicalSpecimen

  validate :value_of_total

  protected

  def value_of_total
    errors.add(:total, "total is not > 1, or nil") if total && not(self.total > 1)
  end

end
