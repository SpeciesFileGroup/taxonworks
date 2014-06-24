require 'spec_helper'

describe TaxonNameRelationship::OriginalCombination do
  context 'respond to' do
    specify 'order_index' do
      genus_index = TaxonNameRelationship::OriginalCombination::OriginalGenus.order_index
      subgenus_index = TaxonNameRelationship::OriginalCombination::OriginalSubgenus.order_index
      expect(genus_index < subgenus_index).to be_truthy
    end
  end
end