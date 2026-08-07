require 'rails_helper'

RSpec.describe CachedMapItem, type: :model, group: [:geo, :cached_map] do

  include_context 'cached map scenario'

  specify '#translate_geographic_item_id 1' do
    expect(CachedMapItem.translate_geographic_item_id(gi2.id, true, true, ['ne_states'])).to contain_exactly(gi1.id)
  end

  specify '#translate_geographic_item_id 2' do
    expect(CachedMapItem.translate_geographic_item_id(gi3.id, true, true, ['ne_states'])).to contain_exactly(gi1.id)
  end

  context 'Gazetteer-backed asserted distributions' do
    let(:otu) { Otu.create(taxon_name: FactoryBot.create(:relationship_genus, parent: FactoryBot.create(:root_taxon_name))) }
    let(:gz) { FactoryBot.create(:valid_gazetteer, geographic_item_id: gi2.id) }
    let(:ad) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu, asserted_distribution_shape: gz) }

    specify 'Translates CachedMapItem' do
      [gz, ad]
      Delayed::Worker.new.work_off
      expect(CachedMapItem.first.geographic_item_id).to eq(gi1.id)
    end

    specify 'Creates CachedMapItemTranslation for Gazetteer-associated GeographicItems' do
      [gz, ad]
      Delayed::Worker.new.work_off
      cmit = CachedMapItemTranslation.first
      expect(cmit.geographic_item_id).to eq(gi2.id)
      expect(cmit.translated_geographic_item_id).to eq(gi1.id)
    end

    specify 'CachedMapItems can be created from line strings' do

      line = 'LINESTRING (2 2, 8 8)'
      gi = GeographicItem.create!(geography: line)
      gz = FactoryBot.create(:valid_gazetteer, geographic_item_id: gi.id)
      FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: otu,asserted_distribution_shape: gz)

      Delayed::Worker.new.work_off
      expect(CachedMapItem.first.geographic_item_id).to eq(gi1.id)
    end
  end

  context 'cached_map disabling conditions:' do
    let(:source) { FactoryBot.create(:valid_source) }
    # Start with an AD that *does* produce a CMI
    let(:ad) {
      AssertedDistribution.new(
        asserted_distribution_object: Otu.new(taxon_name: FactoryBot.create(:relationship_genus, parent: FactoryBot.create(:root_taxon_name))),
        asserted_distribution_shape: FactoryBot.create(:valid_gazetteer),
        citations_attributes: [{ source_id: source.id }]
      )
    }

    specify 'sanity check' do
      ad.save!

      Delayed::Worker.new.work_off
      expect(CachedMapItem.count).to eq(1)
    end

    specify 'no taxon_name_id' do
      ad.asserted_distribution_object = Otu.create!(name: 'no taxon name')
      ad.save!

      Delayed::Worker.new.work_off
      expect(CachedMapItem.count).to eq(0)
    end

    specify 'Asserted distribution is_absent == true' do
      ad.is_absent = true
      ad.save!

      Delayed::Worker.new.work_off
      expect(CachedMapItem.count).to eq(0)
    end
  end

  context 'cached_map enabling conditions:' do
    specify 'Otus for species' do
      s = FactoryBot.create(:relationship_species, parent: FactoryBot.create(:root_taxon_name))
      o = Otu.create!(taxon_name: s)

      AssertedDistribution.create!(
        asserted_distribution_object: o,
        asserted_distribution_shape: FactoryBot.create(:valid_gazetteer),
        citations_attributes: [{ source: FactoryBot.create(:valid_source) }]
      )

      Delayed::Worker.new.work_off
      expect(CachedMapItem.count).to eq(1)
    end
  end

  context 'AD object types other than Otu' do
    let(:otu) { Otu.create!(taxon_name: FactoryBot.create(:relationship_species, parent: FactoryBot.create(:root_taxon_name))) }
    let(:gz) { FactoryBot.create(:valid_gazetteer) }
    let(:source) { FactoryBot.create(:valid_source) }

    def create_ad(object)
      AssertedDistribution.create!(
        asserted_distribution_object: object,
        asserted_distribution_shape: gz,
        citations_attributes: [{ source: }]
      )
    end

    specify 'BiologicalAssociation where OTU is subject creates CachedMapItem for that OTU' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu)
      create_ad(ba)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
    end

    specify 'BiologicalAssociation where OTU is object creates CachedMapItem for that OTU' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_object: otu)
      create_ad(ba)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
    end

    specify 'BiologicalAssociation where same OTU is both subject and object creates one CachedMapItem with reference_count 1' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu, biological_association_object: otu)
      create_ad(ba)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
      expect(CachedMapItem.find_by(otu_id: otu.id).reference_count).to eq(1)
    end

    specify 'BiologicalAssociationsGraph where a BA is a self-relationship creates one CachedMapItem with reference_count 1' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu, biological_association_object: otu)
      bag = FactoryBot.create(:valid_biological_associations_graph)
      FactoryBot.create(:valid_biological_associations_biological_associations_graph,
        biological_associations_graph: bag,
        biological_association: ba
      )
      create_ad(bag)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
      expect(CachedMapItem.find_by(otu_id: otu.id).reference_count).to eq(1)
    end

    specify 'BiologicalAssociationsGraph where same OTU appears in multiple BAs creates one CachedMapItem with reference_count 1' do
      ba1 = FactoryBot.create(:valid_biological_association, biological_association_subject: otu)
      ba2 = FactoryBot.create(:valid_biological_association, biological_association_subject: otu)
      bag = FactoryBot.create(:valid_biological_associations_graph)
      FactoryBot.create(:valid_biological_associations_biological_associations_graph,
        biological_associations_graph: bag,
        biological_association: ba1
      )
      FactoryBot.create(:valid_biological_associations_biological_associations_graph,
        biological_associations_graph: bag,
        biological_association: ba2
      )
      create_ad(bag)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
      expect(CachedMapItem.find_by(otu_id: otu.id).reference_count).to eq(1)
    end

    specify 'BiologicalAssociation with OTUs on both ends creates one CachedMapItem per OTU' do
      otu2 = Otu.create!(taxon_name: FactoryBot.create(:relationship_species, name: 'alba', parent: otu.taxon_name.parent))
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu, biological_association_object: otu2)
      create_ad(ba)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
      expect(CachedMapItem.where(otu_id: otu2.id).count).to eq(1)
    end

    specify 'BiologicalAssociationsGraph with a BA involving the OTU creates CachedMapItem for that OTU' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu)
      bag = FactoryBot.create(:valid_biological_associations_graph)
      FactoryBot.create(:valid_biological_associations_biological_associations_graph,
        biological_associations_graph: bag,
        biological_association: ba
      )
      create_ad(bag)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
    end

    specify 'Conveyance on OTU creates CachedMapItem for that OTU' do
      conveyance = FactoryBot.create(:valid_conveyance, conveyance_object: otu)
      create_ad(conveyance)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
    end

    specify 'Depiction on OTU creates CachedMapItem for that OTU' do
      depiction = FactoryBot.create(:valid_depiction, depiction_object: otu)
      create_ad(depiction)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
    end

    specify 'Observation on OTU creates CachedMapItem for that OTU' do
      observation = FactoryBot.create(:valid_observation, observation_object: otu)
      create_ad(observation)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.where(otu_id: otu.id).count).to eq(1)
    end
  end
end
