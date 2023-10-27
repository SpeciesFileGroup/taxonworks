module RangedLotCategoriesHelper

  def ranged_lot_category_tag(ranged_lot_category)
    return nil if ranged_lot_category.nil?
    ranged_lot_category.name + ': ' + ranged_lot_range(ranged_lot_category)
  end

  def ranged_lot_range(ranged_lot_category)
    [ranged_lot_category.minimum_value, ranged_lot_category.maximum_value].compact.join('-')
  end

end
