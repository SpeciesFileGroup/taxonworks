require 'rails_helper'

describe 'tasks/gis/collection_objects/area_and_date', type: :feature, group: [:geo, :collection_objects] do

  let(:page_index_name) { 'collection objects by area and date' }
  let(:index_path) { index_area_and_date_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  after(:all) { clean_slate_geo }

  context 'signed in as user, with some records created' do
    before {
      sign_in_user_and_select_project
      $user_id = @user.id; $project_id = @project.id
      generate_political_areas_with_collecting_events
    }

    let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }

    describe '#set_area', js: true do #
      it 'renders count of collection objects in a specific names area' do
        visit(index_area_and_date_task_path)
        # {geographic_area_id: GeographicArea.where(name: 'Great Northern Land Mass').first.id})
        # expect(response).to have_http_status(:success)
        # expect(JSON.parse(response.body)['html']).to eq('16')
        fill_autocomplete('geographic_area_id_for_by_area', with: 'Great Northern', select: gnlm.id)
        # expect(page).to have_content('Land Mass')
        click_button('Set')
        expect(find('#area_count')).to have_text('16')
      end

      it 'renders count of collection objects in a drawn area' do
        visit(index_area_and_date_task_path)
        find('.map_toggle').click
        execute_script("document.getElementById('drawn_area_shape').type = 'text'")
        this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
        # this_xpath.set '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}, "properties":{"geographic_item":{"id"=>23}}}'
        this_xpath.set '{"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}'
        # find(:xpath, "//form[@id='set_area_form']/div[@id='map_selector']/div[@id='_drawable_map_outer']/input[@id='drawn_area_shape']").set '{"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}'
        click_button('Set')
        expect(find('#area_count')).to have_text('16')
        # xhr(:get, :set_area, {drawn_area_shape: GeographicArea
        #                                           .where(name: 'Big Boxia')
        #                                           .first
        #                                           .default_geographic_item
        #                                           .to_geo_json_feature})
        # expect(response).to have_http_status(:success)
        # expect(JSON.parse(response.body)['html']).to eq('10')

      end
    end

  end

end
