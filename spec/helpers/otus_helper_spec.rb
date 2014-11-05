require 'rails_helper'

describe OtusHelper, :type => :helper do
  context 'an otu needs some helpers' do
    let(:otu) { FactoryGirl.create(:valid_otu, name: 'voluptas') }

    specify '::otu_tag' do
      expect(OtusHelper.otu_tag(otu)).to eq('voluptas')
    end

    specify '#otu_tag' do
      expect(otu_tag(otu)).to eq('voluptas')
    end

    specify '#otu_link' do
      expect(otu_link(otu)).to have_link('voluptas')
    end

    specify "#otu_search_form" do
      expect(otus_search_form).to have_button('Show')
      expect(otus_search_form).to have_field('otu_id_for_quick_search_form')
    end
  end
end
