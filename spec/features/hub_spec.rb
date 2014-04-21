require 'spec_helper'

describe 'Hub' do
    subject { page }
  before {
    sign_in_valid_user
  }

  describe '/hub' do
    before{
      visit hub_path
    }




    it 'should have a hub title' do
      expect(page).to have_selector('h1', text: 'Hub')
      subject.should have_selector('h1', text: 'Hub')
    end

  end




end
