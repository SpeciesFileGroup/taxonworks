require 'spec_helper'

describe RangedLotCategory do

  let(:ranged_lot_category) {RangedLotCategory.new}


  context 'associations' do 
    context 'has_many' do
      specify 'ranged_lots' do
          expect(ranged_lot_category).to respond_to (:ranged_lots)
      end
    end
  end

  context 'validation' do
    before do
      ranged_lot_category.valid?
    end
    context 'requires' do
      specify 'name' do
        expect(ranged_lot_category.errors.include?(:name)).to be_true
      end

      specify 'name is unique within project' do
        pending
      end

      specify 'when provided, maximum value must be > 0' do
        ranged_lot_category.update(minimum_value: -23, maximum_value: 0)
        ranged_lot_category.valid?
        expect(ranged_lot_category.errors.include?(:maximum_value)).to be_true
      end

      specify 'when provided minimum_value and maximum values are positive integers (or zero)' do
        ranged_lot_category.update(minimum_value: -23, maximum_value: 2)
        ranged_lot_category.valid?
        expect(ranged_lot_category.errors.include?(:minimum_value)).to be_true
      end

      specify 'minimum_value is less than maximum_value when both provided' do
        ranged_lot_category.update(minimum_value: 23)
        ranged_lot_category.valid?
        expect(ranged_lot_category.errors.include?(:maximum_value)).to be_false
        ranged_lot_category.update(minimum_value: 23, maximum_value: 24)
        ranged_lot_category.valid?
        expect(ranged_lot_category.errors.include?(:maximum_value)).to be_false
        ranged_lot_category.update(minimum_value: 23, maximum_value: 23)
        ranged_lot_category.valid?
        expect(ranged_lot_category.errors.include?(:maximum_value)).to be_true 
        ranged_lot_category.update(minimum_value: 100, maximum_value: 1)
        ranged_lot_category.valid?
        expect(ranged_lot_category.errors.include?(:maximum_value)).to be_true
      end
    end
  end
end
