require 'rails_helper'

describe 'Tags', :type => :feature do
  let(:index_path) { tags_path }
  let(:page_title) { 'Tags' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      o = Otu.create!(name: 'Cow', by: @user, project: @project)

      keywords = []
      ['slow', 'medium', 'fast'].each do |n|
        keywords.push FactoryGirl.create(:valid_keyword, name: n, by: @user, project: @project)
      end

      (0..2).each do |i|
        Tag.create!(tag_object: o, keyword: keywords[i], by: @user, project: @project)
      end
    }

    describe 'GET /tags' do
      before {
        visit tags_path
      }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /tags/list' do
      before { visit list_tags_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end


    # pending 'clicking a tag link anywhere renders the tagged object in <some> view'

  end
end

