require 'rails_helper'

RSpec.describe "Pinboards", type: :feature do

  context 'signed in witha project selected' do
    before {sign_in_user_and_select_project}
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

      before {
        Otu.create(name: 'Pinny', by: @user, project: @project)
      }
      
      specify 'create a pin' do # fails with js: true, likely because of js styling of items in recent list
        visit otus_path

        expect(page).to have_link('Pinny')

        click_link('Pinny')
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
end
