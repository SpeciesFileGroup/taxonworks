require 'rails_helper'

describe PreparationTypesHelper, :type => :helper do
  context 'a preparation type needs some helpers' do
    let(:name) {'dangerzone'}
    let(:preparation_type) {FactoryGirl.create(:valid_preparation_type, name:name)}

    specify '::preparation_type_tag' do
      expect(PreparationTypesHelper.preparation_type_tag(preparation_type)).to eq(name)
    end

    specify '#preparation_type_tag' do
      expect(helper.preparation_type_tag(preparation_type)).to eq(name)
    end

    specify '#preparation_type_link' do
      expect(helper.preparation_type_link(preparation_type)).to have_link(name)
    end

    specify "#preparation_type_search_form" do
      expect(helper.preparation_types_search_form).to have_button('Show')
      expect(helper.preparation_types_search_form).to have_field('preparation_type_id_for_quick_search_form')
    end

  end
end
