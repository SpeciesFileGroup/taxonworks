require 'rails_helper'

describe 'Namespaces', :type => :feature do
  let(:page_index_name) { 'Namespaces' }
  
  it_behaves_like 'a_login_required_controller' do
    let(:index_path) { namespaces_path }
  end


  context 'as administrator, with some namespaces built' do
    before do
      sign_in_user
      5.times { factory_girl_create_for_user(:valid_namespace, @administrator) }
    end

    describe 'GET /Namespaces' do
      before do
        visit namespaces_path
      end

    specify 'an index name is present' do
      expect(page).to have_content('Namespaces')
    end
  end
 

    describe 'GET /namespaces/list' do
      before do
        visit list_namespaces_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing namespaces'
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

  context 'creating a new namespace' do
    before {
      sign_in_administrator
      visit namespaces_path #  visit the namespaces_path
    }
    specify 'namespaces_path should have a new link' do
      expect(page).to have_link('new') # it has a new link
    end

    specify 'adding the new namespace' do
      click_link('new') # when I click the new link
      fill_in('Full name', with: 'Things Pat Collected') # and I fill out the Full name field with "Things Pat Collected"
      fill_in('Short name', with: 'tpd') # and I fill out the Short name field with "tpd"
      click_button('Create Namespace') # when I click the 'Create Namespace' button
      # then I get the message "Namespace 'Things Pat Collected' was successfully created"
      expect(page).to have_content("Namespace 'Things Pat Collected' was successfully created")
    end
   end
end

