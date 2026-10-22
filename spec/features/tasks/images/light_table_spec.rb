require 'rails_helper'

describe 'Light table task', type: :feature do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    specify 'the page loads and renders the Vue mount point' do
      visit light_table_task_path

      expect(page.status_code).to eq(200)
      expect(page).to have_css('#light_table_task')
    end
=begin 
    context 'with a saved light table', js: true do
      let(:housekeeping) { {by: @user, project: @project} }
      let(:depiction) do
        Depiction.create!(
          image: FactoryBot.create(:tiny_random_image, **housekeeping),
          depiction_object: FactoryBot.create(:valid_specimen, **housekeeping),
          **housekeeping
        )
      end
      let(:light_table) { FactoryBot.create(:valid_layout_light_table, **housekeeping) }
      let!(:group) do
        LayoutItem::GroupItem.create!(
          composition: light_table, text: 'Group A', x: 100, y: 50, **housekeeping
        )
      end
      let!(:item) do
        LayoutItem::LightTableItem.create!(
          composition: light_table, parent: group, composition_item_object: depiction,
          x: 10.5, y: 20, width: 200, height: 150, zoom: 1.5, rotation_z: 30, opacity: 80, z: 2,
          **housekeeping
        )
      end

      before do
        visit light_table_task_path(composition_id: light_table.id)
        expect(page).to have_css('.lt-item', count: 1)
      end

      specify 'it is rendered without changes to save' do
        expect(page).to have_css('.lt-region', text: 'Group A')
        expect(page).to have_text('All changes saved')
        name = find('.light-table-save-bar__name', text: light_table.name)
        radial = find('button.btn-radial')
        expect(radial.rect.y).to be_within(20).of(name.rect.y)
      end

      specify 'a change is saved as an update to the item' do
        find('.lt-item').click
        click_button 'Unassign'
        expect(page).to have_text('1 unsaved change(s)')

        click_button 'Save'
        expect(page).to have_text('All changes saved')

        item.reload
        expect(item.parent_id).to be_nil
        # The group's offset moves into the item, which stays where it was
        expect(item.x).to eq(110.5)
        expect(item.y).to eq(70)
        expect([item.zoom, item.rotation_z, item.opacity, item.z]).to eq([1.5, 30, 80, 2])
      end

      specify 'an image can be rotated from its context menu' do
        find('.lt-item').right_click
        find('.lt-context-menu button', text: 'Transform').hover
        find('.lt-context-menu button', text: 'Rotate 90° right').click

        expect(page).not_to have_css('.lt-context-menu')
        click_button 'Save'
        expect(page).to have_text('All changes saved')
        expect(item.reload.rotation_z).to eq(120)
      end

      specify 'the stacking options are in the Arrange submenu' do
        find('.lt-item').right_click
        expect(page).not_to have_button('Bring to front')

        find('.lt-context-menu button', text: 'Arrange').click
        within('.lt-submenu__panel') do
          expect(page).to have_button('Bring to front')
          expect(page).to have_button('Send to back')
        end
      end

      specify 'the group options are in the Group submenu' do
        find('.lt-item').right_click
        find('.lt-context-menu button', text: 'Group').click
        find('.lt-context-menu button', text: 'Move to').click

        expect(page).to have_button('Group A', disabled: true)
        find('.lt-context-menu button', text: 'Remove from group').click
        expect(page).to have_text('1 unsaved change(s)')
      end

      specify 'the context menu opens the radial navigator of the depicted object' do
        find('.lt-item').right_click
        find('.lt-context-menu button', text: 'Navigation').click
        within(find('.lt-context-menu button', text: 'Navigation').ancestor('.lt-submenu')) do
          expect(page).to have_button('Image')
          expect(page).to have_button('Depiction')
          find('button', text: 'Collection object').click
        end

        expect(page).to have_css('.radial-annotator')
      end

      specify 'the selection panel lists each selected image' do
        find('.lt-item').click

        within('.panel', text: 'Selection') do
          expect(page).to have_text('1 selected')
          expect(page).to have_css('.light-table-selection__row', count: 1)
          expect(page).to have_text('Group A')
          find('.light-table-selection__row button[aria-label="Deselect"]').click
          expect(page).to have_text('Nothing selected')
        end
      end

      specify 'the batch actions menu groups the selection by type' do
        find('.lt-item').click
        find('button[aria-label="Batch actions"]').click

        within('.light-table-selection-radials__menu') do
          expect(page).to have_button('Image (1)')
          expect(page).to have_button('Depiction (1)')

          find('button', text: 'Image (1)').click
          within(find('button', text: 'Image (1)').ancestor('.lt-submenu')) do
            expect(page).to have_button('Radial filter')
            expect(page).not_to have_button('Radial collection object')
          end

          find('button', text: 'Collection object (1)').click
          within(find('button', text: 'Collection object (1)').ancestor('.lt-submenu')) do
            find('button', text: 'Radial collection object').click
          end
        end

        expect(page).to have_css('.modal-container', text: 'Radial collection object')
      end

      specify 'a group color is saved in its css_style' do
        page.execute_script(<<~JS)
          const input = document.querySelector('.lt-region-chip__swatch input')
          input.value = '#00ff00'
          input.dispatchEvent(new Event('input', { bubbles: true }))
        JS
        expect(page).to have_text('1 unsaved change(s)')

        click_button 'Save'
        expect(page).to have_text('All changes saved')
        expect(group.reload.css_style).to eq('--region-color: #00ff00')

        visit light_table_task_path(composition_id: light_table.id)
        expect(page).to have_css('.lt-item', count: 1)
        expect(page).to have_text('All changes saved')
        expect(find('.lt-region-chip__swatch input', visible: :all).value).to eq('#00ff00')
      end

      context 'with two images in the group' do
        let!(:other_item) do
          LayoutItem::LightTableItem.create!(
            composition: light_table, parent: group,
            composition_item_object: Depiction.create!(
              image: FactoryBot.create(:tiny_random_image, **housekeeping),
              depiction_object: FactoryBot.create(:valid_specimen, **housekeeping),
              **housekeeping
            ),
            x: 400, y: 300, width: 200, height: 150, **housekeeping
          )
        end

        specify 'they can be arranged in a row' do
          visit light_table_task_path(composition_id: light_table.id)
          expect(page).to have_css('.lt-item', count: 2)

          find('.lt-region__header').right_click
          find('.lt-context-menu button', text: 'Layout').click
          find('.lt-context-menu button', text: 'Row').click
          click_button 'Save'
          expect(page).to have_text('All changes saved')

          # Same height, so a shared center line means the same y
          expect(other_item.reload.y).to eq(item.reload.y)
          expect(other_item.x).to be > item.x
        end
      end

      specify 'a group header has its own context menu' do
        find('.lt-region__header').right_click

        within('.lt-context-menu') do
          expect(page).to have_text('Group A')
          expect(page).to have_button('Layout')
          expect(page).not_to have_button('Grid')
        end
      end

      specify 'a new group is saved before its members' do
        find('.lt-item').click
        click_button 'New group'
        click_button 'Save'
        expect(page).to have_text('All changes saved')

        item.reload
        expect(item.parent.text).to eq('New group')
        expect(item.parent.id).not_to eq(group.id)
        expect(item.x + item.parent.x).to be_within(0.01).of(110.5)
        expect(item.y + item.parent.y).to be_within(0.01).of(70)
      end
    end

    specify 'a light table can be opened from the Open light table modal', js: true do
      light_table = FactoryBot.create(:valid_layout_light_table, by: @user, project: @project)
      visit light_table_task_path

      click_button 'Open'
      within('.modal-container') do
        find('tr', text: light_table.name).find('button[aria-label="Edit light table"]').click
      end

      expect(page).to have_css('.light-table-save-bar__name', text: light_table.name)
      expect(page).to have_text('All changes saved')
    end

    specify 'the task opens on a new, empty light table that is created on save', js: true do
      visit light_table_task_path

      expect(page).to have_css('.lt-canvas')
      expect(page).to have_text('Not saved yet')

      fill_in placeholder: 'Name this light table to save it', with: 'My plate'
      click_button 'Save'

      expect(page).to have_css('.light-table-save-bar__name', text: 'My plate')
      expect(page).to have_text('All changes saved')
      expect(Layout::LightTable.where(name: 'My plate').count).to eq(1)
    end

    specify 'images sent from a filter are placed on a new light table', js: true do
      image = FactoryBot.create(:tiny_random_image, by: @user, project: @project)
      visit light_table_task_path(image_id: [image.id])

      expect(page).to have_css('.lt-item', count: 1)
      expect(page).to have_text('Not saved yet')

      find('.lt-item').right_click
      find('.lt-context-menu button', text: 'Remove from table').click
      expect(page).not_to have_css('.lt-item')

      within('.panel', text: 'Add images') do
        expect(page).to have_text('From filter')
        find('.light-table-sources__thumb').click
      end
      expect(page).to have_css('.lt-item', count: 1)

      fill_in placeholder: 'Name this light table to save it', with: 'From filter'
      click_button 'Save'
      expect(page).to have_text('All changes saved')

      light_table = Layout::LightTable.find_by(name: 'From filter')
      expect(light_table.composition_items.first.composition_item_object).to eq(image)
    end
=end
  end
end
