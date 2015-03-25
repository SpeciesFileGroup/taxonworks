require 'rails_helper'

describe 'Namespaces', :type => :feature do
  let(:page_index_name) { 'namespaces' }
  let(:index_path) { namespaces_path }

  it_behaves_like 'a_login_required_controller'

  context 'as administrator, with some records created' do
    # todo @mjy, why is it important that this be an administrator?
    before do
      sign_in_user
      5.times { factory_girl_create_for_user(:valid_namespace, @administrator) }
    end

    describe 'GET /Namespaces' do
      before do
        visit namespaces_path
      end

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /namespaces/list' do
      before do
        visit list_namespaces_path
      end

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /namespaces/n' do
      before do
        visit namespace_path(Namespace.second)
      end

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context 'creating a new namespace' do
    before {
      sign_in_administrator
      visit namespaces_path #  visit the namespaces_path
    }

    # This was already tested above.
    # specify 'namespaces_path should have a new link' do
    #   expect(page).to have_link('new') # it has a new link
    # end

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

