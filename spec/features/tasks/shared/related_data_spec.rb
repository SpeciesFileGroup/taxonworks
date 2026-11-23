require 'rails_helper'

describe 'Related data task', type: :feature do

  context 'when signed in and a project is selected' do
    before do
      sign_in_user_and_select_project
      Current.user_id = @user.id
      Current.project_id = @project.id
    end

    def visit_related(object)
      visit related_data_task_path(object_global_id: object.to_global_id.to_s)
    end

    def status
      page.driver.response.status
    end

    specify 'shows a record in this project' do
      visit_related(FactoryBot.create(:valid_otu))
      expect(status).to eq(200)
    end

    specify 'does not show a record in another project' do
      other = FactoryBot.create(:valid_project, by: @user)
      visit_related(FactoryBot.create(:valid_otu, project: other))
      expect(status).to eq(404)
    end

    context 'records without a project' do
      specify 'shows an annotation of a community object' do
        i = Identifier::Global::Issn.create!(
          identifier_object: FactoryBot.create(:valid_serial),
          identifier: '2049-3630'
        )
        expect(i.reload.project_id).to be_nil

        visit_related(i)
        expect(status).to eq(200)
      end

      specify 'shows a community Template' do
        allow(Template).to receive(:community_permitted?).and_return(true)
        t = Template.create!(name: 'Shared', is_community: true)
        expect(t.project_id).to be_nil

        visit_related(t)
        expect(status).to eq(200)
      end

      specify 'does not show a record that does not declare itself community' do
        n = News::Project::Notice.create!(
          title: 'Notice', body: 'Body', project: @project,
          display_start: 1.day.ago, display_end: 1.day.from_now
        )
        n.update_column(:project_id, nil)

        visit_related(n)
        expect(status).to eq(404)
      end
    end

    specify 'shows a non-pinnable record without a pin link' do
      l = Layout.create!(name: 'Table')
      visit_related(l)
      expect(status).to eq(200)
      expect(page).to have_content('Task - Related data')
    end
  end
end
