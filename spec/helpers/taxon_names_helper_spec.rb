require 'rails_helper'

describe TaxonNamesHelper, type: :helper do
  let(:taxon_name) {FactoryBot.create(:valid_protonym) }

  specify '#taxon_name_autocomplete_tag 1' do
    expect(helper.taxon_name_autocomplete_tag(taxon_name, 'Aus (')).to be_truthy
  end

  specify '#taxon_name_for_select' do
    expect(helper.taxon_name_for_select(taxon_name)).to eq('Aaidae')
  end

  specify '#parent_taxon_name_for_select' do
    expect(helper.parent_taxon_name_for_select(taxon_name)).to eq('Root')
  end

  specify '#taxon_name_tag' do
    expect(helper.taxon_name_tag(taxon_name)).to eq('Aaidae')
  end

  specify '#taxon_name_link' do
    expect(helper.taxon_name_link(taxon_name)).to have_link('Aaidae')
  end

  specify '#taxon_name_rank_select_tag' do
    expect(helper.taxon_name_rank_select_tag(taxon_name: taxon_name, code: :iczn)).to have_select('taxon_name_rank_class')
  end

  context 'taxon_name_inventory_stats' do
    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:family) { Protonym.create!(name: 'Cicadellidae', rank_class: Ranks.lookup(:iczn, :family), parent: root) }
    let!(:family_otu) { Otu.create!(taxon_name: family) }

    let!(:genus1) { Protonym.create!(name: 'Erythroneura', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus1_otu) { Otu.create!(taxon_name: genus1) }
    let!(:genus2) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus2_otu) { Otu.create!(taxon_name: genus2) }
    let!(:genus3) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus3_otu) { Otu.create!(taxon_name: genus3) }
    let!(:genus4) { Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus4_otu) { Otu.create!(taxon_name: genus4) }
    let!(:genus5) { Protonym.create!(name: 'Dus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus5_otu) { Otu.create!(taxon_name: genus5) }

    let!(:genus6) { Protonym.create!(name: 'Fus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
    let!(:genus6_otu) { Otu.create!(taxon_name: genus6) }
    let!(:genus7) { Protonym.create!(name: 'Gus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
    let!(:genus7_otu) { Otu.create!(taxon_name: genus7) }

    let!(:tnr1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: genus1, object_taxon_name: genus2) }
    let!(:tnr2) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: genus5, object_taxon_name: genus6) }
    let!(:tnr3) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: genus7, object_taxon_name: genus3) }

    let!(:tnc) { TaxonNameClassification::Iczn::Fossil.create!(taxon_name: genus4) }

    let!(:stats) { taxon_name_inventory_stats(family) }

    specify 'count' do
      expect(stats.count).to eq(2)
    end

    specify 'ranks' do
      expect(stats.map{|x| x[:rank]}).to eq([:family, :genus])
    end

    context 'genus' do
      let!(:g) { stats.find { |r| r[:rank] == :genus } }

      specify 'names valid' do
        expect(g[:names][:valid]).to eq(3) # g2, g3, g4
      end

      specify 'names invalid' do
        # Invalid pulls from outside descendants and self; valid does not.
        expect(g[:names][:invalid]).to eq(3) # g1, g5, g6
      end

      specify 'names valid_extant' do
        expect(g[:names][:valid_extant]).to eq(2)
      end

      specify 'names valid_fossil' do
        expect(g[:names][:valid_fossil]).to eq(1)
      end

      specify 'taxa' do
        # Pulls in invalids, does not pull in valids, so genus6 is not included.
        expect(g[:taxa]).to eq(6)
      end
    end
  end

  context "invalid is counted at valid's rank only" do
    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:family) { Protonym.create!(name: 'Cicadellidae', rank_class: Ranks.lookup(:iczn, :family), parent: root) }
    let!(:genus1) { Protonym.create!(name: 'Erythroneura', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus1_otu) { Otu.create!(taxon_name: genus1) }
    let!(:genus2) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus2_otu) { Otu.create!(taxon_name: genus2) }
    let!(:genus3) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }

    let!(:subgenus1) { Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :subgenus), parent: genus1) }
    let!(:subgenus1_otu) { Otu.create!(taxon_name: subgenus1) }
    let!(:subgenus2) { Protonym.create!(name: 'Dus', rank_class: Ranks.lookup(:iczn, :subgenus), parent: root) }
    let!(:subgenus2_otu) { Otu.create!(taxon_name: subgenus2) }
    let!(:subgenus3) { Protonym.create!(name: 'Fus', rank_class: Ranks.lookup(:iczn, :subgenus), parent: root) }
    let!(:subgenus3_otu) { Otu.create!(taxon_name: subgenus3) }

    let!(:tnr1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: subgenus1, object_taxon_name: genus1) }
    let!(:tnr2) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: subgenus2, object_taxon_name: genus2) }
    let!(:tnr3) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: genus3, object_taxon_name: subgenus3) }

    let!(:stats) { taxon_name_inventory_stats(family) }
    let(:g) { stats.find { |r| r[:rank] == :genus } }
    let(:sg) { stats.find { |r| r[:rank] == :subgenus } }

    specify 'invalid of different rank than valid is counted at valid rank only' do
      expect(g[:names][:valid]).to eq(2) # g1, g2
      expect(g[:names][:invalid]).to eq(2) # g3, sg3
      expect(sg[:names][:valid]).to eq(0) # only invalid sg1 has family as ancestor
      expect(sg[:names][:invalid]).to eq(1) # sg1 (valid name g1 is in the same family tree, it was counted above)
    end

    specify "taxa pulls invalid in to valid's rank, does not pull in invalid" do
      expect(g[:taxa]).to eq(4) # g1, g2, sg1, sg2
      expect(sg[:taxa]).to eq(0) # g3 doesn't have an otu
    end
  end
end
