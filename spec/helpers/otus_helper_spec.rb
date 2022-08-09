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
end
