require 'spec_helper'

# TODO: this is a join

describe 'SerialChronologies' do

  it_behaves_like 'a_login_required_controller' do 
    let(:index_path) { serial_chronologies_path }
    let(:page_index_name) { 'Serial Chronologies' }
  end 

  describe 'GET /serial_chronologies' do
    before { 
      sign_in_user_and_select_project 
      visit serial_chronologies_path }
    specify 'an index name is present' do
      expect(page).to have_content('Serial Chronologies')
    end
  end
end

