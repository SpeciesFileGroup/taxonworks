# A TemplateItem is one part of a reusable Template structure.
#
class TemplateItem < CompositionItem

  validates_presence_of :composition
  validate :composition_is_template

  protected

  def composition_is_template
    if composition && !composition.is_a?(Template)
      errors.add(:composition, 'must be a Template')
    end
  end

end
