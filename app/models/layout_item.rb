# A LayoutItem places a specific thing in a Layout.
#
class LayoutItem < CompositionItem

  validates_presence_of :composition
  validate :composition_is_layout

  protected

  def composition_is_layout
    if composition && !composition.is_a?(Layout)
      errors.add(:composition, 'must be a Layout')
    end
  end

end
