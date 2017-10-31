require 'rails_helper'

describe 'tasks/otus/filter', type: :feature, group: [:geo, :otus] do
  context 'with properly built collection of objects' do
    let(:page_title) { 'Otus by area' }
    let(:index_path) { otus_filter_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    after(:all) {
      clean_slate_geo
      CollectionObject.destroy_all
      Namespace.destroy_all
    }

    context 'signed in as a user' do
      before(:each) {
        sign_in_user_and_select_project
      }

      context 'with some records created' do
        before {
          generate_political_areas_with_collecting_events(@user.id, @project.id)
        }

        let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }

        let!(:otum1) { Otu.where(name: 'Find me').first }

        let(:json_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}' }

        describe '#set_area', js: true do #
          it 'renders count of otus in a specific names area' do
            visit(index_path)
            page.execute_script "$('#set_area')[0].scrollIntoView()"
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'Great Northern', select: gnlm.id)
            click_button('Set area')
            expect(find('#area_count')).to have_text('14')
          end

          it 'renders count of otus in a drawn area' do
            visit(index_path)
            find('#label_toggle_slide_area').click
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
            this_xpath.set json_string
            click_button('Set area')
            expect(find('#area_count')).to have_text('10')
          end
        end

        describe '#find', js: true do
          before {
            visit(index_path)
            # find('#area_picker_autocomplete').set('Great')
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'Great Northern', select: gnlm.id)
            click_button('Set area')
            wait_for_ajax
            find('#find_area_and_nomen_commit').click
            wait_for_ajax
          }

          it 'renders count of objects and table found using a drawn area and date range' do
            find('#area_count', visible: true, text: '14')
            expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Catalog Number')
          end
        end
      end
    end
  end
end

