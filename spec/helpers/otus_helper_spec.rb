require 'rails_helper'

describe OtusHelper, type: :helper do
  let(:otu) { FactoryBot.create(:valid_otu, name: 'voluptas') }

  specify '#otu_tag' do
    expect(helper.otu_tag(otu)).to eq('<span class="otu_tag"><span class="otu_tag_otu_name" title="1">voluptas</span></span>')
  end

  specify '#otu_link' do
    expect(helper.otu_link(otu)).to have_link('voluptas')
  end

  specify '#otu_search_form' do
    expect(helper.otus_search_form).to have_field('otu_id_for_quick_search_form')
  end

  specify '#otu_cataloug' do
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
