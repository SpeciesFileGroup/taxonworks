require 'rails_helper'

describe 'Downloads', type: :feature do
  let(:index_path) { downloads_path }
  let(:page_title) { 'Downloads' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_bot_create_for_user_and_project(:valid_download, @user, @project) }
    }

    describe 'GET /downloads' do
      before { visit downloads_path }

      it_behaves_like 'a_data_model_with_standard_index', true
    end

    describe 'GET /downloads/list' do
      before { visit list_downloads_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    # TODO: Think about testing actual image download. Probably will be fixed by a status
    #       check service or sanity check script (with default image on database).
    # page.should have_xpath("//img[contains(@src, 'mona_lisa.jpg')]")
    # xdescribe 'GET /api/v1/images/{id}' do
    #   before do
    #     @user.generate_api_access_token
    #     @user.save!
    #   end
    #   let(:image) { factory_bot_create_for_user_and_project(:valid_image, @user, @project) }
    #
    #   it 'Returns a downloadable link to the image' do
    #     visit "/api/v1/images/#{image.to_param}?project_id=#{@project.to_param}&token=#{@user.api_access_token}"
    #     visit JSON.parse(page.body)['result']['url']
    #     expect(page.status_code).to eq(200)
    #   end
    # end

  end
end
