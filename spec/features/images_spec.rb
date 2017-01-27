require 'rails_helper'

describe "Images", :type => :feature do
  let(:index_path) { images_path }
  let(:page_title) { 'Images' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_girl_create_for_user_and_project(:valid_image, @user, @project) }
    }

    describe 'GET /images' do
      before { visit images_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /images/list' do
      before { visit list_images_path }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /images/n' do
      before { visit image_path(Image.second) }

      it_behaves_like 'a_data_model_with_standard_show'
    end

    # TODO: Think about testing actual image download. Probably will be fixed by a status
    #       check service or sanity check script (with default image on database).
    # page.should have_xpath("//img[contains(@src, 'mona_lisa.jpg')]")
    # xdescribe 'GET /api/v1/images/{id}' do
    #   before do
    #     @user.generate_api_access_token
    #     @user.save!
    #   end
    #   let(:image) { factory_girl_create_for_user_and_project(:valid_image, @user, @project) }
    #
    #   it 'Returns a downloadable link to the image' do
    #     visit "/api/v1/images/#{image.to_param}?project_id=#{@project.to_param}&token=#{@user.api_access_token}"
    #     visit JSON.parse(page.body)['result']['url']
    #     expect(page.status_code).to eq(200)
    #   end
    # end


    context 'testing new image browse' do
      before {
        #   logged in and project selected
        visit images_path }

      # @todo Need to reconcile path to test images
      # specify 'can browse to upload existing image', js: true do
      #   click_link('new')
      #   expect(page).to have_content("Select an image through the browser")

        # click_button('Browse...')
        # attach_file "Tiny", "/files/images/tiny.png"
        # click_button('Create Image')
        # expect(page).to have_content("Image was successfully created.")
      # end
    end

  end
end
