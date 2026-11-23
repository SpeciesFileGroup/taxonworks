require 'rails_helper'

describe PreparationTypesHelper, type: :helper do
  context 'a preparation type needs some helpers' do
    let(:name) {'dangerzone'}
    let(:definition) {'Highway to the'}
    let(:preparation_type) {FactoryBot.create(:valid_preparation_type, name:, definition:)}

    specify '#preparation_type_tag' do
      expect(helper.preparation_type_tag(preparation_type)).to eq(name)
    end

    specify '#label_for_preparation_type' do
      expect(helper.label_for_preparation_type(preparation_type)).to eq(name)
    end

    specify '#preparation_type_autocomplete_tag includes the definition' do
      expect(helper.preparation_type_autocomplete_tag(preparation_type)).to eq("<span>#{name}: #{definition}</span>")
    end

    specify '#preparation_type_autocomplete_tag marks the term' do
      expect(helper.preparation_type_autocomplete_tag(preparation_type, 'danger')).to include('<mark>danger</mark>')
    end

    specify '#preparation_type_link' do
      expect(helper.preparation_type_link(preparation_type)).to have_link(name)
    end

    specify '#preparation_type_search_form' do
      expect(helper.preparation_types_search_form).to have_field('preparation_type_id_for_quick_search_form')
    end

  end
end
