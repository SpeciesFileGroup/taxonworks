require 'rails_helper'

describe GeographicAreasController, type: :controller do
  before(:each) {
    sign_in
  }

  let!(:earth) { FactoryBot.create(:earth_geographic_area) }
  let(:geographic_area_type) {FactoryBot.create(:valid_geographic_area_type)}

  after(:all) {
    GeographicArea.delete_all
  }

  #let(:valid_attributes) {
  #  strip_housekeeping_attributes( FactoryBot.build(:valid_geographic_area).attributes.merge(geographic_area_type_id: geographic_area_type.id, parent_id: earth.id ) )
  #}

  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns recent geographic_areas as @recent_objects' do
      geographic_area_4 = FactoryBot.create(:level2_geographic_area)
      four_id           = geographic_area_4.id
      geographic_area_3 = GeographicArea.find(four_id - 1)
      geographic_area_2 = GeographicArea.find(four_id - 2)
      geographic_area_1 = GeographicArea.find(four_id - 3)
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects).include?(geographic_area_1)).to eq(true)
      expect(assigns(:recent_objects).include?(geographic_area_2)).to eq(true)
      expect(assigns(:recent_objects).include?(geographic_area_3)).to eq(true)
      expect(assigns(:recent_objects).include?(geographic_area_4)).to eq(true)
    end
  end

  describe 'GET show' do
    it 'assigns the requested geographic_area as @geographic_area' do
      geographic_area = FactoryBot.create(:level2_geographic_area)
      get :show, params: {id: geographic_area.to_param}, session: valid_session
      expect(assigns(:geographic_area)).to eq(geographic_area)
    end
  end

  describe 'GET list' do
    it 'assigns the requested geographic_areas as @geographic_areas' do
      geographic_area = FactoryBot.create(:level2_geographic_area)
      get :list, params: {}, session: valid_session
      expect(assigns(:geographic_areas).count).to be > 1
    end
  end

end
