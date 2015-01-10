require 'rails_helper'

describe 'PreparationTypes', :type => :feature do

  it_behaves_like 'an_administrator_login_required_controller' do
    let(:index_path) { preparation_types_path }
    let(:page_index_name) { 'PreparationTypes' }
  end

  describe 'GET /PreparationTypes' do
    before do
      sign_in_administrator
      visit preparation_types_path
    end

    specify 'an index name is present' do
      expect(page).to have_content('Preparation types')
    end
  end

  context 'as administrator, with some preparation_types built' do
    before do
      sign_in_administrator
      5.times { factory_girl_create_for_user(:valid_preparation_type, @administrator) }
    end

    describe 'GET /preparation_types/list' do
      before do
        visit list_preparation_types_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing preparation types'
      end
    end

    describe 'GET /preparation_types/n' do
      before do
        visit  preparation_type_path(PreparationType.second) # Note second!
      end

      specify 'there is a \'previous\' link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a \'next\' link' do
        expect(page).to have_link('Next')
      end
    end
  end
end

