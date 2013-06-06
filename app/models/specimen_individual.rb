class SpecimenIndividual < Specimen

  validate :total_must_be_one

  protected

  def total_must_be_one
   errors.add(:total, "total is not 1") if self.total != 1
  end

end
