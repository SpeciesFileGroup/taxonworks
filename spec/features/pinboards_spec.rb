require 'rails_helper'

RSpec.describe "Pinboards", type: :feature do

  context 'signed in witha project selected' do
    before {sign_in_user_and_select_project}
    context 'pinning items' do
      let!(:o) { Otu.create(name: 'Pinny', by: @user, project: @project) }

      context 'when on a show page' do
        before do
          visit otu_path(o)
        end

        specify 'a Pin link is visible' do # fails with js: true, likely because of js styling of items in recent list
          expect(page.has_link?('Pin')).to be_truthy
        end

        context 'when Pin is clicked' do
          before {     click_link('Pin') }

          specify 'page refreshes and shows as Pinned' do
            expect(page).to have_content('Pinned')
          end

          specify 'and link is gone (should be changed to "Unpin"!)' do 
            expect(page.has_link?('Pin')).to be_falsey
          end

          context 'when root path is visited' do
            before {        visit root_path }
            specify 'item is listed on pinboard' do
              expect(page).to have_selector('h3', 'Otus')
              expect(page).to have_link('Pinny')
            end
          end
        end
      end
    end
  end 
end
