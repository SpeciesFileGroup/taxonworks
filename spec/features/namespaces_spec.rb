require 'rails_helper'

describe 'Namespaces', :type => :feature do

  it_behaves_like 'an_administrator_login_required_controller' do
    let(:index_path) { namespaces_path }
    let(:page_index_name) { 'Namespaces' }
  end

  describe 'GET /Namespaces' do
    before do
      sign_in_administrator
      visit namespaces_path
    end
    
    specify 'an index name is present' do
      expect(page).to have_content('Namespaces')
    end
  end
 
  context 'as administrator, with some namespaces built' do
    before do
      sign_in_administrator
      5.times { factory_girl_create_for_user(:valid_namespace, @administrator) }
    end

    describe 'GET /namespaces/list' do
      before do
        visit list_namespaces_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Namespaces'
      end
    end

    describe 'GET /namespaces/n' do
      before do
        visit  namespace_path(Namespace.second) # Note second!
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








