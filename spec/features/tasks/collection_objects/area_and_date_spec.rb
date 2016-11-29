require 'rails_helper'

describe 'tasks/gis/collection_objects/area_and_date', type: :feature, group: [:geo, :collection_objects] do

  context 'with properly built collection of objects' do

    let(:page_index_name) { 'collection objects by area and date' }
    let(:index_path) { index_area_and_date_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    before {
    }

    after(:all) { clean_slate_geo }

    context 'signed in as user, with some records created' do
      before {
        sign_in_user_and_select_project
        $user_id = @user.id; $project_id = @project.id
        generate_political_areas_with_collecting_events(@user_id, @project_id)
      }
      let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }
      # let(:json_string) { eval('{"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}').to_json }
      let(:json_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}' }

      describe '#set_area', js: true do #
        it 'renders count of collection objects in a specific names area' do
          visit(index_area_and_date_task_path)
          # {geographic_area_id: GeographicArea.where(name: 'Great Northern Land Mass').first.id})
          # expect(response).to have_http_status(:success)
          # expect(JSON.parse(response.body)['html']).to eq('16')
          fill_autocomplete('geographic_area_id_for_by_area', with: 'Great Northern', select: gnlm.id)
          # expect(page).to have_content('Land Mass')
          click_button('Set area')
          expect(find('#area_count')).to have_text('16')
        end

        it 'renders count of collection objects in a drawn area' do
          visit(index_area_and_date_task_path)
          find('.map_toggle').click
          execute_script("document.getElementById('drawn_area_shape').type = 'text'")
          this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
          # this_xpath.set '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}, "properties":{"geographic_item":{"id"=>23}}}'
          this_xpath.set json_string
          # find(:xpath, "//form[@id='set_area_form']/div[@id='map_selector']/div[@id='_drawable_map_outer']/input[@id='drawn_area_shape']").set '{"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}'
          click_button('Set area')
          expect(find('#area_count')).to have_text('10')
          # xhr(:get, :set_area, {drawn_area_shape: GeographicArea
          #                                           .where(name: 'Big Boxia')
          #                                           .first
          #                                           .default_geographic_item
          #                                           .to_geo_json_feature})
          # expect(response).to have_http_status(:success)
          # expect(JSON.parse(response.body)['html']).to eq('10')

        end
      end

      describe '#set_date', js: true do
        it 'renders count of collection objects based on the start and end dates' do
          visit(index_area_and_date_task_path)
          c_wait = Capybara.default_max_wait_time
          Capybara.default_max_wait_time = 60
          execute_script("document.getElementById('search_start_date').value = '1971/01/01'")
          execute_script("document.getElementById('search_end_date').value = '1980/12/31'")
          find('#search_start_date').set('1971/01/01')
          # find_search_start_date = find('#search_start_date')
          # find_search_start_date.set '1971/01/01'
          # find('#search_end_date').set('1980/12/31')
          # find_search_end_date = find('#search_end_date')
          # find_search_end_date.set('1980/12/31')
          # check('partial_overlap')
          # execute_script("document.getElementById('toggle_slide_calendar').click()")
          find('#search_end_date').click
          # find_search_start_date.set '1971/01/01'
          # find('#search_start_date').click
          expect(find('#date_count')).to have_content('10')
          Capybara.default_max_wait_time = c_wait
        end
      end

      describe '#find', js: true do
        drawn_area_shape = '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [34, 28, 0], [34, 24, 0], [33, 24, 0], [33, 28, 0]]]}}'
        it 'renders count of objects and table found using a drawn area and date range' do
          visit(index_area_and_date_task_path)
          find('#search_start_date').set '1971/01/01'
          find('#search_end_date').set '1980/12/31'
          #find('#search_start_date').click
          find('.map_toggle').click
          execute_script("document.getElementById('drawn_area_shape').type = 'text'")
          this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
          this_xpath.set drawn_area_shape
          find('#find_area_and_date_commit').click
          expect(find('#result_span')).to have_text('Total: 3')
          expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Catalog Number')
        end

      end
    end
  end
end

