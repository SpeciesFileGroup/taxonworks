require 'rails_helper'

describe Tasks::CollectionObjects::AreaAndDateController, type: :controller do
  # include DataControllerConfiguration::ProjectDataControllerConfiguration

  before(:all) {
    # sign_in
    generate_political_areas_with_collecting_events
  }
  before(:each) {
    sign_in
  }
  after(:all) { clean_slate_geo }

  describe 'GET #index' do
    it 'returns http success' do
      get(:index)
      expect(response).to have_http_status(:success)
    end
  end

  describe '#set_area' do
    it 'renders count of collection objects in a specific names area' do
      get(:set_area, {geographic_area_id: GeographicArea.where(name: 'Great Northern Land Mass').first.id})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('13')
    end

    it "renders count of collection objects in a drawn area" do
      # {"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}
      get(:set_area, {drawn_area_shape: GeographicArea
                                          .where(name: 'Big Boxia')
                                          .first
                                          .default_geographic_item
                                          .to_geo_json_feature})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('7')
    end
  end

  describe '#set_date' do
    it "renders count of collection objects based on the start and end dates" do
      get(:set_date, {st_flexpicker: Date.yesterday.to_s, en_flexpicker: Date.tomorrow.to_s})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('17')
    end

  end
end
