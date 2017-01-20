require 'rails_helper'

describe 'Administration', :type => :feature do 
 
  it_behaves_like 'an_administrator_login_required_controller' do
    let(:index_path) { administration_path }
    let(:page_title) { 'Administration' }
  end

  describe 'GET /otus' do
    before { 
      sign_in_administrator
    }
    specify 'an administration link is present' do
      expect(page).to have_link('Administration')
    end
  end


end
