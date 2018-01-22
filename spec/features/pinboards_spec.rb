require 'rails_helper'

RSpec.describe 'Pinboards', type: :feature do

  context 'signed in with a project selected' do
    before {sign_in_user_and_select_project}
    context 'pinning items' do
      let!(:o) { Otu.create(name: 'Pinny', by: @user, project: @project) }

      context 'when on a show page', js: true do
        before do
          visit otu_path(o)
        end

        specify 'a Pin link is visible' do 
          expect(page).to have_css('a.pin-button')
        end

        context 'when Pin is clicked' do
          before { find('.pin-button').click}

          specify 'page refreshes and shows as Pinned' do
            expect(page).to have_css('a.unpin-button')
          end

          context 'when clicked again reverts' do
            before { find('.unpin-button').click}

            specify 'a Pin link is visible' do 
              expect(page).to have_css('a.pin-button')
            end
          end

        end
      end
    end
  end
end
