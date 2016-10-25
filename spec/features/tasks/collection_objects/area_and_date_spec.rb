require 'rails_helper'

describe 'tasks/gis/collection_objects/area_and_date', type: :feature, group: [:geo, :collection_objects] do

  before(:all) {
    sign_in_user_and_select_project
    generate_political_areas_with_collecting_events
  }
  after(:all) { clean_slate_geo }

  let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }

  describe '#set_area' do
    it 'renders count of collection objects in a specific names area' do
      visit(index_area_and_date_task_path)
      # {geographic_area_id: GeographicArea.where(name: 'Great Northern Land Mass').first.id})
      # expect(response).to have_http_status(:success)
      # expect(JSON.parse(response.body)['html']).to eq('16')
      fill_autocomplete('geographic_area_id_for_by_area', with: 'Great Northern', select: gnlm.id)
      # expect(page).to have_content('Land Mass')
      click_button('Set')
      expect(page).to have_text('16')
    end

    it 'renders count of collection objects in a drawn area' do
      # {"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}
      visit(index_area_and_date_task_path)
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
