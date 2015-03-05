class Identifier::Global::Lsid < Identifier::Global
  validate :using_lsid_class

  def using_lsid_class
    unless identifier.nil?
      lsid = identifier

      errors.add(:identifier, "'#{identifier}' is not a valid LSID.")
      return false
    end
  end
end
