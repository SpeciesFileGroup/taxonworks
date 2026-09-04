require 'rails_helper'

describe OtusHelper, type: :helper do
  let(:otu) { FactoryBot.create(:valid_otu, name: 'voluptas') }

  # See app/helpers/otus/render_spec.html for tag and label specs

  describe '#otu_tag_taxon_name_css_classes' do
    specify 'a valid name gets the neutral element only' do
      taxon_name = FactoryBot.create(:relationship_species)
      expect(helper.otu_tag_taxon_name_css_classes(taxon_name)).to eq([:otu_tag_taxon_name])
    end

    specify 'a synonym is marked invalid' do
      junior_taxon_name = FactoryBot.create(:relationship_species)
      senior_taxon_name = FactoryBot.create(:relationship_species)
      TaxonNameRelationship.create!(subject_taxon_name: junior_taxon_name,
        object_taxon_name: senior_taxon_name,
        type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')

      expect(helper.otu_tag_taxon_name_css_classes(junior_taxon_name.reload)).to include(:otu_tag_taxon_name_invalid)
    end

    specify 'a combination is marked as such, not as invalid' do
      combination = FactoryBot.create(:valid_combination)
      expect(helper.otu_tag_taxon_name_css_classes(combination)).to eq([:otu_tag_taxon_name, :otu_tag_taxon_name_combination])
    end

    specify 'no taxon name gets the neutral element only' do
      expect(helper.otu_tag_taxon_name_css_classes(nil)).to eq([:otu_tag_taxon_name])
    end
  end

  specify '#otu_link' do
    expect(helper.otu_link(otu)).to have_link('voluptas')
  end

  specify '#otu_search_form' do
    expect(helper.otus_search_form).to have_field('otu_id_for_quick_search_form')
  end

  specify '#otu_catalog' do
    f = FactoryBot.create(:iczn_family, name: 'Cicadidae')
    g1 = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: f)
    g2 = Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: f)
    t = Protonym.create!(name: 'Ausini', rank_class: Ranks.lookup(:iczn, :tribe), parent: f)
    sf = Protonym.create!(name: 'Cicadinae', rank_class: Ranks.lookup(:iczn, :subfamily), parent: f)

    o1 = Otu.create!(taxon_name: f)
    o2 = Otu.create!(taxon_name: g1)

    o5 = Otu.create!(taxon_name: sf)
    o4 = Otu.create!(taxon_name: t)

    o3 = Otu.create!(taxon_name: g2)


    expect(helper.otu_descendants_and_synonyms(o1)[:descendants].collect{|i| i[:otu_id]}).to eq([o5.id, o4.id, o3.id, o2.id])
  end
  
end
