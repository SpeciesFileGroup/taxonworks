require 'rails_helper'

describe 'ProjectOrganizations', type: :feature do
  let(:index_path) { project_organizations_path }
  let(:page_title) { 'Project organizations' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before { sign_in_user_and_select_project }

    let!(:organization) { Organization.create!(name: 'Vulcan Science Academy', by: @user) }
    let!(:project_organization) {
      ProjectOrganization.create!(organization:, project: @project, by: @user)
    }

    describe 'GET /project_organizations' do
      before { visit project_organizations_path }

      specify 'renders' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'GET /project_organizations/list' do
      before { visit list_project_organizations_path }

      specify 'lists the organization' do
        expect(page).to have_text(organization.name)
      end
    end

    describe 'GET /project_organizations/:id' do
      before { visit project_organization_path(project_organization) }

      specify 'renders' do
        expect(page).to have_text(organization.name)
      end
    end
  end

end
