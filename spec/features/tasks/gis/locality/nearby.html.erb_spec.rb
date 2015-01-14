require 'rails_helper'

describe "tasks/gis/locality/nearby.html.erb", :type => :feature do

  # it_behaves_like 'a_login_required_and_project_selected_controller' do
  #   let(:index_path) { tasks_gis_locality_nearby_path }
  #   let(:page_index_name) { 'Collecting Events' }
  # end

  before(:all) do
    sign_in_user_and_select_project
    generate_ce_test_objects
  end

  # before(:each) do
    # @user = assign(:user,
    #                stub_model(User,
    #                           :email           => "MyString",
    #                           :password_digest => "MyString",
    #                           :created_by_id   => 1,
    #                           :updated_by_id   => 1
    #                ))
  # end

  after(:all) do
    clean_slate_geo
  end

  it 'renders the collecting_events_nearby partial' do
    @collecting_event = @ce_p1
    # visit collecting_events_path(@collecting_event.to_param)
    visit ("tasks/gis/locality/nearby/#{@collecting_event.id}")
    # pending "add some examples to (or delete) #{__FILE__}"
    expect(page).to have_content(/Task: Nearby localities/)
  end

end
