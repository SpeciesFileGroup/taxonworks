# For use with Morphbank specimens, currently just a number
# e.g. 855664

class Identifier::Global::MorphbankSpecimenNumber < Identifier::Global
  validate :is_number

  def is_number
    if identifier.present?
      # If non-number characters are in the string, invalid format
      if /\D/.match(identifier)
        errors.add(:identifier, 'invalid format, only numbers allowed')
      end
    end
  end
end
