require 'rails_helper'

describe OtusHelper, :type => :helper do
  let(:otu) { FactoryGirl.create(:valid_otu, name: 'voluptas') }

  specify '#otu_tag' do
    expect(helper.otu_tag(otu)).to eq('voluptas')
  end

  specify '#otu_link' do
    expect(helper.otu_link(otu)).to have_link('voluptas')
  end

  specify "#otu_search_form" do
    expect(helper.otus_search_form).to have_button('Show')
    expect(helper.otus_search_form).to have_field('otu_id_for_quick_search_form')
  end
end
