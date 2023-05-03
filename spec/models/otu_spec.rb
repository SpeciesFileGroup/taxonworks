require 'rails_helper'

describe Otu, type: :model, group: :otu do

  let(:otu) { Otu.new }

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameHierarchy.delete_all
  end

  context 'parent otu' do

    specify '#parent_otu_id 1' do
      t0 = Protonym.create!(name: 'Ayo', rank_class: Ranks.lookup(:iczn, :order), parent: FactoryBot.create(:root_taxon_name))
      t = Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: t0)
      t1 = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: t)

      o0 = Otu.create(taxon_name:t0)
      o1 = Otu.create(taxon_name:t)
      o2 = Otu.create(taxon_name:t1)
      expect(o2.parent_otu_id).to eq(o1.id)
    end

    specify '#parent_otu_id 2' do
      t0 = Protonym.create!(name: 'Ayo', rank_class: Ranks.lookup(:iczn, :order), parent: FactoryBot.create(:root_taxon_name))
      t = Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: t0)
      t1 = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: t)

      o0 = Otu.create(taxon_name: t)
      o1 = Otu.create(taxon_name: t)
      o2 = Otu.create(taxon_name: t1)
      expect(o2.parent_otu_id).to eq(false)
    end

    specify '#parent_otu_id 3' do
      t0 = Protonym.create!(name: 'Ayo', rank_class: Ranks.lookup(:iczn, :order), parent: FactoryBot.create(:root_taxon_name))
      t = Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: t0)
      t1 = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: t)

      o2 = Otu.create(taxon_name:t1)
      expect(o2.parent_otu_id).to eq(nil)
    end
  end

  context 'associations' do
    context 'has many' do
      specify 'taxon determinations' do
        expect(otu.taxon_determinations << TaxonDetermination.new).to be_truthy
      end

      specify 'contents' do
        expect(otu.contents << Content.new).to be_truthy
      end

      specify 'topics' do
        expect(otu.content_topics << Topic.new).to be_truthy
      end
    end
  end

  specify 'without #name or #taxon_name_id is invalid' do
    expect(otu.valid?).to be_falsey
  end

  specify 'valid assigned a taxon_name, not taxon_name_id, nor id' do
    otu.taxon_name = Protonym.create!(name: 'Ayo', rank_class: Ranks.lookup(:iczn, :order), parent: FactoryBot.create(:root_taxon_name))
    expect(otu.valid?).to be_truthy
  end

  specify 'invalid assigned a non-persisted taxon_name' do
    otu.taxon_name = Protonym.new
    expect(otu.valid?).to be_falsey
  end

  specify '#name' do
    expect(otu).to respond_to(:name)
  end

  # TODO: Deprecate for helper method
  specify '#otu_name should be the taxon name cached_html' do
    expect(otu.otu_name).to eq(nil)

    t = FactoryBot.create(:relationship_species)
    t.reload
    expect(t.valid?).to be_truthy

    otu.taxon_name = t
    expect(otu.otu_name).to eq('<i>Erythroneura vitis</i> McAtee, 1900')

    otu.name = 'Foo'
    expect(otu.otu_name).to eq('Foo')
  end

  context 'coordination and scope' do
    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:g) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
    let!(:s1) { Protonym.create!(name: 'bus', parent: g, rank_class: Ranks.lookup(:iczn, :species)) } # valid
    let!(:s2) { Protonym.create!(name: 'cus', parent: g, rank_class: Ranks.lookup(:iczn, :species)) } # invalid

    let!(:r) { TaxonNameRelationship::Iczn::Invalidating.create!(subject_taxon_name: s2, object_taxon_name: s1) }

    let!(:o1) { Otu.create!(taxon_name: s1) }
    let!(:o2) { Otu.create!(taxon_name: s2) }
    let!(:o3) { Otu.create!(name: 'none') }

    specify '.descendant_of_taxon_name 1' do
      expect(Otu.descendant_of_taxon_name(root.id)).to contain_exactly(o1, o2)
    end

    specify '.descendant_of_taxon_name 2' do
      expect(Otu.descendant_of_taxon_name(s1.id)).to contain_exactly(o1, o2)
    end

    specify '.descendant_of_taxon_name 3' do
      expect(Otu.descendant_of_taxon_name(s2.id)).to contain_exactly()
    end

    specify '.coordinate_otus 1' do
      expect(Otu.coordinate_otus(o1.id).map(&:id)).to contain_exactly(o1.id, o2.id)
    end

    specify '.coordinate_otus 2' do
      expect(Otu.coordinate_otus(o2.id).map(&:id)).to contain_exactly(o1.id, o2.id)
    end

    specify '.coordinate_otus 3' do
      expect(Otu.coordinate_otus(o3.id).map(&:id)).to contain_exactly(o3.id)
    end

    specify '#coordinate_with? 1' do
      expect(o1.coordinate_with?(o1.id)).to be_truthy
    end

    specify '#coordinate_with? 2' do
      expect(o1.coordinate_with?(o2.id)).to be_truthy
    end

    specify '#coordinate_with? 3' do
      expect(o2.coordinate_with?(o1.id)).to be_truthy
    end

    specify '#coordinate_with? 4' do
      expect(o3.coordinate_with?(o1.id)).to be_falsey
    end
  end

  context 'complex interactions' do
    context 'distribution' do
      let(:a_d1) { FactoryBot.create(:valid_asserted_distribution) }
      let(:a_d2) { FactoryBot.create(:valid_asserted_distribution) }
      let(:a_d3) { FactoryBot.create(:valid_asserted_distribution) }
      let(:otu1) { a_d1.otu }
      let(:otu2) { a_d2.otu }
      let(:c_e1) { FactoryBot.create(:valid_collecting_event) }
      let(:c_e2) { FactoryBot.create(:valid_collecting_event) }
      let(:c_e3) { FactoryBot.create(:valid_collecting_event) }
      let(:c_o1) { FactoryBot.create(:valid_collection_object, {collecting_event: c_e1}) }
      let(:c_o2) { FactoryBot.create(:valid_collection_object, {collecting_event: c_e2}) }
      let(:c_o3) { FactoryBot.create(:valid_collection_object, {collecting_event: c_e3}) }

      let(:t_d1) { FactoryBot.create(:valid_taxon_determination, {otu: otu1, biological_collection_object: c_o1}) }

      let(:t_d2) { FactoryBot.create(:valid_taxon_determination, {otu: otu2, biological_collection_object: c_o2}) }
      let(:t_d3) { FactoryBot.create(:valid_taxon_determination, {otu: otu1, biological_collection_object: c_o3}) }

      before(:each) {
        a_d3.otu = otu1
        [a_d1, a_d2, a_d3,
         otu1, otu2,
         c_e1, c_e2, c_e3,
         c_o1, c_o2, c_o3,
         t_d1, t_d2, t_d3].map(&:save)
      }

      specify 'the otu can find its asserted distribution' do
        a_ds1 = otu1.asserted_distributions
        a_ds2 = otu2.asserted_distributions
        expect(a_ds1.count).to eq(2)
        expect(a_ds1).to contain_exactly(a_d1, a_d3)
        expect(a_ds2.count).to eq(1)
        expect(a_ds2).to contain_exactly(a_d2)
      end

      specify 'the otu can find its taxon_determinations' do
        t_ds1 = otu1.taxon_determinations
        expect(t_ds1.count).to eq(2)
        expect(t_ds1).to contain_exactly(t_d1, t_d3)

        t_ds2 = otu2.taxon_determinations
        expect(t_ds2.count).to eq(1)
        expect(t_ds2).to contain_exactly(t_d2)
      end

      specify 'the otu can find its collecting_events' do
        c_es1 = otu1.collecting_events
        expect(c_es1.count).to eq(2)
        expect(c_es1).to contain_exactly(c_e1, c_e3)

        c_es2 = otu2.collecting_events
        expect(c_es2.count).to eq(1)
        expect(c_es2).to contain_exactly(c_e2)
      end
    end
  end

  context 'scopes' do
    let!(:t) { FactoryBot.create(:relationship_species) }
    let!(:o) { Otu.create(taxon_name: t) }

    specify '.for_taxon_name(taxon_name) handles integers' do
      expect(Otu.for_taxon_name(t.to_param)).to contain_exactly(o)
    end

    specify '.for_taxon_name(taxon_name) handles taxon name instance' do
      expect(Otu.for_taxon_name(t)).to contain_exactly(o)
    end

    specify '.for_taxon_name(taxon_name) handles nestedness' do
      expect(Otu.for_taxon_name(t.parent)).to contain_exactly(o)
    end
  end

  context 'used recently' do
    before do
      otu.name = 'Foo recently'
      otu.save!
      PinboardItem.create!(pinned_object: o2, is_inserted: true, user_id: 1)
    end

    let(:o2) { Otu.create(name: 'o2') }
    let(:s) { FactoryBot.create(:valid_specimen) }
    let!(:content) { FactoryBot.create(:valid_content, otu: otu) }
    let!(:biological_association) { FactoryBot.create(:valid_biological_association, biological_association_subject: o2, biological_association_object: otu) }
    let!(:asserted_distribution) { FactoryBot.create(:valid_asserted_distribution, otu: otu) }

    specify ".used_recently('Content')" do
      expect(Otu.used_recently(otu.created_by_id, otu.project_id,'Content').to_a).to include(otu.id)
    end

    specify ".used_recently('BiologicalAssociation')" do
      expect(Otu.used_recently(otu.created_by_id, otu.project_id,'BiologicalAssociation').to_a).to include(otu.id)
    end

    specify '.selected_optimized 1' do
      expect(Otu.select_optimized(otu.created_by_id, otu.project_id, 'BiologicalAssociation')[:recent].map(&:id) ).to contain_exactly(otu.id, o2.id)
    end

    specify '.selected_optimized 2' do
      expect(Otu.select_optimized(otu.created_by_id, otu.project_id, 'Content')[:quick].map(&:id)).to contain_exactly(otu.id, o2.id)
    end

    specify '.selected_optimized 3' do
      expect(Otu.select_optimized(otu.created_by_id, otu.project_id, 'AssertedDistribution')[:quick].map(&:id)).to contain_exactly(otu.id, o2.id)
    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'data_attributes'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
