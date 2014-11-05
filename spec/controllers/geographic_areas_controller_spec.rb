require 'rails_helper'

describe GeographicAreasController, :type => :controller do
  before(:each) {
    sign_in 
  }

  let!(:earth) { FactoryGirl.create(:earth_geographic_area) } 
  let(:geographic_area_type) {FactoryGirl.create(:valid_geographic_area_type)}

  after(:all) {
    GeographicArea.delete_all
  }
  
   #let(:valid_attributes) { 
   #  strip_housekeeping_attributes( FactoryGirl.build(:valid_geographic_area).attributes.merge(geographic_area_type_id: geographic_area_type.id, parent_id: earth.id ) )
   #} 

  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns recent geographic_areas as @recent_objects' do
      geographic_area_5 = FactoryGirl.create(:level2_geographic_area)
      geographic_area_4 = GeographicArea.find(geographic_area_5.id - 1)
      geographic_area_3 = GeographicArea.find(geographic_area_5.id - 2)
      geographic_area_2 = GeographicArea.find(geographic_area_5.id - 3)
      geographic_area_1 = GeographicArea.find(geographic_area_5.id - 4)
      get :index, {}, valid_session
      expect(assigns(:recent_objects).include?(geographic_area_1)).to eq(true)
      expect(assigns(:recent_objects).include?(geographic_area_2)).to eq(true)
      expect(assigns(:recent_objects).include?(geographic_area_3)).to eq(true)
      expect(assigns(:recent_objects).include?(geographic_area_4)).to eq(true)
      expect(assigns(:recent_objects).include?(geographic_area_5)).to eq(true)
    end
  end

  describe 'GET show' do
    it 'assigns the requested geographic_area as @geographic_area' do
      geographic_area = FactoryGirl.create(:level2_geographic_area)
      get :show, {:id => geographic_area.to_param}, valid_session
      expect(assigns(:geographic_area)).to eq(geographic_area)
    end
  end

  describe 'GET list' do
    it 'assigns the requested geographic_areas as @geographic_areas' do
      geographic_area = FactoryGirl.create(:level2_geographic_area)
      get :list, {}, valid_session
      expect(assigns(:geographic_areas).count).to be > 1 
    end
  end

end
