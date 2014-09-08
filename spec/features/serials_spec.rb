require 'rails_helper'

describe 'Serials', :type => :feature do

  it_behaves_like 'a_login_required_controller' do 
    let(:index_path) { serials_path }
    let(:page_index_name) { 'Serials' }
  end 

  describe 'GET /serials' do  # list all serials <serials#index>
    before { 
      sign_in_user_and_select_project 
      visit serials_path }
    specify 'an index name is present' do
      expect(page).to have_content('Serials')
    end
  end

  describe 'GET /serials/:id'  do # display a particular serial <serials#show>
    before {
      sign_in_user
      $user_id = 1
      @serial = FactoryGirl.create(:valid_serial) #create auto saves
      visit serial_path(@serial)
    }
    specify 'should see serial attributes' do
      expect(page).to have_content(@serial.name)
    end

  end
end

