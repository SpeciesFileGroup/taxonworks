require 'spec_helper'

describe TaxonNameRelationship::Combination do
  context 'respond to' do
    specify 'order_index' do
      genus_index = TaxonNameRelationship::Combination::Genus.order_index
      subgenus_index = TaxonNameRelationship::Combination::Subgenus.order_index
      expect(genus_index < subgenus_index).to be_true
    end
  end
end