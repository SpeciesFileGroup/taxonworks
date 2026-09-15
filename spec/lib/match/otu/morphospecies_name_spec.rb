require 'rails_helper'

describe Match::Otu::MorphospeciesName, type: :model do
  let(:root)  { FactoryBot.create(:root_taxon_name) }
  let(:genus) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }

  let!(:otu) { Otu.create!(taxon_name: genus, name: 'code1') }

  let(:project_id) { genus.project_id }

  def match(names:, **opts)
    Match::Otu::MorphospeciesName.new(names:, project_id:, **opts).call
  end

  specify 'exact genus + otu_name match' do
    result = match(names: ['Aus code1']).first
    expect(result[:matched]).to be true
    expect(result[:taxon_name_id]).to eq(genus.id)
    expect(result[:otus].map(&:id)).to contain_exactly(otu.id)
    expect(result[:ambiguous]).to be false
  end

  specify 'wrong genus does not match' do
    result = match(names: ['Bus code1']).first
    expect(result[:matched]).to be false
    expect(result[:otus]).to be_empty
  end

  specify 'wrong otu name does not match' do
    result = match(names: ['Aus code2']).first
    expect(result[:matched]).to be false
  end

  specify 'one-word input does not match' do
    result = match(names: ['Aus']).first
    expect(result[:matched]).to be false
  end

  specify 'three-word input does not match' do
    result = match(names: ['Aus bus code1']).first
    expect(result[:matched]).to be false
  end

  specify 'preserves order and dedups repeated names' do
    result = match(names: ['Aus code1', 'nomatch', 'Aus code1'])
    expect(result.map { |r| r[:scientific_name] }).to eq(['Aus code1', 'nomatch', 'Aus code1'])
    expect(result[0][:matched]).to be true
    expect(result[2][:matched]).to be true
  end

  context 'ambiguous' do
    let!(:other_family) { Protonym.create!(name: 'Busidae', rank_class: Ranks.lookup(:iczn, :family), parent: root) }
    let!(:other_genus) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: other_family) }
    let!(:other_otu) { Otu.create!(taxon_name: other_genus, name: 'code1') }

    specify 'homonym genera each with a same-named otu are flagged ambiguous' do
      result = match(names: ['Aus code1']).first
      expect(result[:matched]).to be true
      expect(result[:ambiguous]).to be true
      expect(result[:otus].map(&:id)).to contain_exactly(otu.id, other_otu.id)
    end
  end

  specify 'an otu on a same-named Subgenus (e.g. the nominotypical subgenus) does not match' do
    subgenus = Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :subgenus), parent: genus)
    Otu.create!(taxon_name: subgenus, name: 'code1')

    result = match(names: ['Aus code1']).first
    expect(result[:otus].map(&:id)).to contain_exactly(otu.id)
    expect(result[:ambiguous]).to be false
  end

  context 'taxon_name_id scope' do
    let!(:other_family) { Protonym.create!(name: 'Busidae', rank_class: Ranks.lookup(:iczn, :family), parent: root) }
    let!(:other_genus) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: other_family) }
    let!(:other_otu) { Otu.create!(taxon_name: other_genus, name: 'code1') }

    specify 'excludes genera outside scope' do
      result = match(names: ['Aus code1'], taxon_name_id: other_family.id).first
      expect(result[:matched]).to be true
      expect(result[:otus].map(&:id)).to contain_exactly(other_otu.id)
      expect(result[:ambiguous]).to be false
    end
  end
end
