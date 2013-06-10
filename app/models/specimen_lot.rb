class SpecimenLot < PhysicalSpecimen

  validate :value_of_total

  protected

  def value_of_total
    # In order to evaluate the value of 'total', we need to see that it:
    #   a)  has been set (i.e., is NOT nil)
    # AND
    #   b)  is more than 1
    #
    # alternately, the evaluation must fail if it:
    #   a)  is nil
    # OR
    #   b)  is NOT > 2
    # OR
    #   c)  is NOT of class Fixnum
    # errors.add(:total, "total is not > 1, or nil") if self.total.nil? || (self.total < 2 || self.total.class != Fixnum)
    errors.add(:total, "total is not > 1, or is nil") if self.total && (not(self.total > 1))

  end

end
