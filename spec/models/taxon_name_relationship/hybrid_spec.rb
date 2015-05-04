require 'rails_helper'

describe TaxonNameRelationship::Hybrid, :type => :model do
  context 'validate' do
    specify 'validate_rank_group' do
      h = FactoryGirl.create(:valid_hybrid)
      g = h.ancestor_at_rank('genus')
      s = FactoryGirl.create(:icn_species, parent: g)

      expect(h.valid?).to be_truthy
      r1 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: s, object_taxon_name: h, type: 'TaxonNameRelationship::Hybrid')
      expect(r1.valid?).to be_truthy
      r2 = FactoryGirl.build_stubbed(:taxon_name_relationship, subject_taxon_name: g, object_taxon_name: h, type: 'TaxonNameRelationship::Hybrid')
      expect(r2.valid?).to be_falsey
    end
  end
end