require 'rails_helper'

describe 'DataAttributes', :type => :feature do
  let(:index_path) { data_attributes_path }
  let(:page_index_name) { 'Data attributes' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      # todo @mjy, need to build object explicitly with user and project
      # 10.times { factory_girl_create_for_user_and_project(:valid_data_attribute, @user, @project) }
    }

    describe 'GET /data_attributes' do
      before {
        visit data_attributes_path }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    # todo @mjy, following lines commented out until we can create a valid object
    #   describe 'GET /data_attributes/list' do
    #     before { visit list_alternate_values_path }
    #
    #     it_behaves_like 'a_data_model_with_standard_list'
    #   end

    specify 'add a data attribute' do
=begin
with an OTU created
with a Predicate created
     when I click on show for that otu
          then there is a "Add data attribute" link
          when I click on that link
             and I select the Predicate from the ajax selector
             and I enter the value "42"
             when I click "Create Data attribute"
                 then I get the message "Data attribute successfully created."
                 and I can see the predicate rendered under annotations/data attributes

=end
      # signed in above
      otu = Otu.new(name: 'a', by: @user, project: @project)
      otu.save!

      # create a predicate (controlled vocabulary term)
    end
  end
end
