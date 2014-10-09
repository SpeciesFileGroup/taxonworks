require 'rails_helper'

describe 'Contents', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { contents_path }
    let(:page_index_name) { 'Contents' }
  end

  context 'when signed in an a project is selected' do
    before {
      sign_in_user_and_select_project
    }

    describe 'GET /contents' do
      before { visit contents_path }

      specify 'an index name is present' do
        expect(page).to have_content('Contents')
      end
    end

    context 'with some content created' do
      let!(:o) { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
      let!(:t) { factory_girl_create_for_user_and_project(:valid_topic, @user, @project) } 
      before do
        30.times {
          FactoryGirl.create(:valid_otu_content,
                             otu: o, 
                             topic: t,
                             project: @project,
                             creator: @user,
                             updater: @user
                            )
        }
      end

      describe 'GET /contents/list' do
        before { visit list_contents_path}
        specify 'that it renders without error' do
          expect(page).to have_content 'Listing Contents'
        end
      end

      describe 'GET /contents/n' do
        before { visit content_path(Content.second) }
        specify 'there is a \'previous\' link' do
          expect(page).to have_link('Previous')
        end

        specify 'there is a \'next\' link' do
          expect(page).to have_link('Next')
        end
      end
    end
  end
end
