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
    let(:root) { FactoryBot.create(:root_taxon_name) }
    let(:family) { Protonym.create!(name: 'Cicadellidae', rank_class: Ranks.lookup(:iczn, :family), parent: root) }
    let!(:genus1) { Protonym.create!(name: 'Erythroneura', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus2) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus3) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus4) { Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:tnr) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: genus1, object_taxon_name: genus2) }
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
        expect(g[:names][:valid]).to eq(3)
      end

      specify 'names invalid' do
        expect(g[:names][:invalid]).to eq(1)
      end

      specify 'names valid_extant' do
        expect(g[:names][:valid_extant]).to eq(2)
      end

      specify 'names valid_fossil' do
        expect(g[:names][:valid_fossil]).to eq(1)
      end
    end
  end

  context "invalid is counted at valid's rank" do
    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:family) { Protonym.create!(name: 'Cicadellidae', rank_class: Ranks.lookup(:iczn, :family), parent: root) }
    let!(:genus1) { Protonym.create!(name: 'Erythroneura', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus2) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:subgenus1) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :subgenus), parent: genus1) }

    let!(:tnr) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: subgenus1, object_taxon_name: genus2) }

    let!(:stats) { taxon_name_inventory_stats(family) }
    let(:g) { stats.find { |r| r[:rank] == :genus } }
    let(:sg) { stats.find { |r| r[:rank] == :subgenus } }

    specify 'invalid of different rank than valid is counted only at valid rank' do
      expect(g[:names][:valid]).to eq(2)
      expect(g[:names][:invalid]).to eq(1)
      expect(sg[:names][:valid]).to eq(0)
      expect(sg[:names][:invalid]).to eq(0)
    end
  end
end
