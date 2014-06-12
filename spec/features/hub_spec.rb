require 'spec_helper'

describe 'Hub' do

  it_behaves_like 'a_login_required_controller' do 
    let(:index_path) { hub_path }
  end 

  subject { page }
  before {
    sign_in_valid_user
  }

  describe '/hub' do
    before {
      visit hub_path
    }

    it 'should have a hub title' do
      expect(page).to have_selector('h1', text: 'Hub')
      subject.should have_selector('h1', text: 'Hub')
    end

  end
end
