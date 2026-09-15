require 'rails_helper'

describe 'Organizations', type: :feature do
  let(:index_path) { organizations_path }
  let(:page_title) { 'Organizations' }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as a user, with some records created' do
    before { sign_in_user_and_select_project }

    let!(:organization) { Organization.create!(name: 'Vulcan Science Academy', by: @user) }

    describe 'GET /organizations' do
      before { visit organizations_path }

      specify 'the quick search form is available' do
        expect(page).to have_field('organization_id_for_quick_search_form')
        expect(page).not_to have_text('Search form not yet available.')
      end
    end

    describe 'GET /organizations/:id' do
      before { visit organization_path(organization) }

      specify 'the quick search form is available' do
        expect(page).to have_field('organization_id_for_quick_search_form')
      end
    end

    describe 'GET /organizations/search' do
      specify 'with an id redirects to show' do
        visit search_organizations_path(id: organization.id)
        expect(page).to have_current_path(organization_path(organization))
      end

      specify 'without an id redirects to index' do
        visit search_organizations_path
        expect(page).to have_current_path(organizations_path)
      end
    end
  end
end
