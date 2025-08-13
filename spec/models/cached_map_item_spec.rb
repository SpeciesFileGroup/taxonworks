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

    specify 'species group taxon_name_id' do
      g = ad.asserted_distribution_object.taxon_name
      ad.asserted_distribution_object = Otu.create!(taxon_name: FactoryBot.create(:relationship_species, parent: g))
      ad.save!

      Delayed::Worker.new.work_off
      expect(CachedMapItem.count).to eq(0)
    end

    specify 'combination' do
      g = ad.asserted_distribution_object.taxon_name
      s = FactoryBot.create(:relationship_species, parent: g, name: 'aus', year_of_publication: 1900, verbatim_author: 'McAtee')
      c = Combination.create!(genus: g, species: s)
      ad.asserted_distribution_object = Otu.create!(taxon_name: c)
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

end
