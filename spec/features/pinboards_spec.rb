require 'rails_helper'

RSpec.describe "Pinboards", :type => :feature do

  context 'pinning items' do
=begin
  with an otu created (named "Pinny")
  when I show that otu
  there is an 'Add to pinboard' link
  when I click that link
  there is a message 'Pinboard item was successfully created.'
  and the link is gone
  and a message exists: 'this record is pinned!'
  when I then show dashboard
  then I see a header 'Otus' under Pinboard
  and I ses a link to 'Pinny'
=end
    specify 'create a pin', js:true do
      # added js:true for debugging purposes only
      sign_in_user_and_select_project
      otu = Otu.new(name: 'Pinny', by: @user, project: @project)
      otu.save!
      visit otus_path
      expect(page).to have_link('Pinny')
      click_link('Pinny')
      # expect(page).to have_link('Add to pinboard')
      expect(page.has_link?('Add to pinboard')).to be_truthy

      click_link('Add to pinboard')
      expect(page).to have_content('Pinboard item was successfully created.')
      expect(page).to have_content('this record is pinned!')
      expect(page.has_link?('Add to pinboard')).to be_falsey

      visit root_path
      expect(page).to have_selector('h3', 'Otus')
      expect(page).to have_link('Pinny')
    end
  end
 
end
