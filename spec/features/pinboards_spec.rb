require 'rails_helper'

RSpec.describe "Pinboards", type: :feature do

  context 'signed in with a project selected' do
    before {sign_in_user_and_select_project}
    context 'pinning items' do
      let!(:o) { Otu.create(name: 'Pinny', by: @user, project: @project) }

      context 'when on a show page', js: true do
        before do
          visit otu_path(o)
        end

        specify 'a Pin link is visible' do 
          expect(page.has_link?('Pin')).to be_truthy
        end

        context 'when Pin is clicked' do
          before { click_link('Pin') }

          specify 'page refreshes and shows as Pinned' do
            expect(page).to have_content('Pinned')
          end

          specify 'and link is styled differently' do
            expect(page).to have_css('span.pin-button.disable-button')
          end

          context 'when clicked again reverts' do
            before { click_link('Pinned') }

            specify 'a Pin link is visible' do 
              expect(page.has_link?('Pin')).to be_truthy
            end
          end

        end
      end
    end
  end
end
