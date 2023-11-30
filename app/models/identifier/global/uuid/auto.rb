# A generic auto-added Uuuid by taxonworks.  Not necessarily in the DwC generation process,
# but likely replacing those in the generation process.
#
class Identifier::Global::Uuid::Auto < Identifier::Global::Uuid
  validate :no_other_uuids

  def no_other_uuids
    if identifier_object.persisted?
      errors.add(:identifier_object, 'UUID alread exists on this object') if ::Identifier::Global::Uuid.where(identifier_object:).any?
    end
  end

end
