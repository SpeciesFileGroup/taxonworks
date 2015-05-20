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
    specify 'cached values' do
      g = FactoryGirl.create(:icn_genus, name: 'Aus')
      s1 = FactoryGirl.build(:icn_species, name: 'bus', parent: g)
      s2 = FactoryGirl.build(:icn_species, name: 'aus', parent: g)
      s1.save
      s2.save
      h = FactoryGirl.build(:valid_hybrid)
      h.save
      expect(h.cached).to eq('[HYBRID TAXA NOT SELECTED]')
      expect(h.cached_html).to eq('[HYBRID TAXA NOT SELECTED]')
      r1 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s1, object_taxon_name: h, type: 'TaxonNameRelationship::Hybrid')
      h.reload
      r2 = FactoryGirl.create(:taxon_name_relationship, subject_taxon_name: s2, object_taxon_name: h, type: 'TaxonNameRelationship::Hybrid')
      h.reload
      expect(h.cached).to eq('Aus aus &#215; Aus bus')
      expect(h.cached_html).to eq('<em>Aus aus</em> &#215; <em>Aus bus</em>')
    end

  end
end