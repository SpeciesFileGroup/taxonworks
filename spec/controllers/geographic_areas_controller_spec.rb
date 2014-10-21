require 'rails_helper'

describe GeographicAreasController, :type => :controller do
  before(:each) {
    sign_in 
  }

  let!(:earth) { FactoryGirl.create(:earth_geographic_area) } 

  after(:all) {
    GeographicArea.delete_all
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:geographic_area_type) {FactoryGirl.create(:valid_geographic_area_type)}
  let(:valid_attributes) { 
    strip_housekeeping_attributes( FactoryGirl.build(:valid_geographic_area).attributes.merge(geographic_area_type_id: geographic_area_type.id, parent_id: earth.id ) )
  } 

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GeographicAreasController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns all geographic_areas as @geographic_areas' do
      # geographic_area = GeographicArea.create! valid_attributes
      geographic_area_5 = FactoryGirl.create(:level2_geographic_area)
      geographic_area_4 = GeographicArea.find(geographic_area_5.id - 1)
      geographic_area_3 = GeographicArea.find(geographic_area_5.id - 2)
      geographic_area_2 = GeographicArea.find(geographic_area_5.id - 3)
      geographic_area_1 = GeographicArea.find(geographic_area_5.id - 4)
      get :index, {}, valid_session
      expect(assigns(:geographic_areas).order('id').to_a).to eq([geographic_area_1,
                                                             geographic_area_2,
                                                             geographic_area_3,
                                                             geographic_area_4,
                                                             geographic_area_5])
    end
  end

  describe 'GET show' do
    it 'assigns the requested geographic_area as @geographic_area' do
      geographic_area = FactoryGirl.create(:level2_geographic_area)
      get :show, {:id => geographic_area.to_param}, valid_session
      expect(assigns(:geographic_area)).to eq(geographic_area)
    end
  end

  describe 'GET new' do
    it 'assigns a new geographic_area as @geographic_area' do
      get :new, {}, valid_session
      expect(assigns(:geographic_area)).to be_a_new(GeographicArea)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested geographic_area as @geographic_area' do
      geographic_area = FactoryGirl.create(:level2_geographic_area)
      get :edit, {:id => geographic_area.to_param}, valid_session
      expect(assigns(:geographic_area)).to eq(geographic_area)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new GeographicArea' do
        expect {
          post :create, {geographic_area: valid_attributes }, valid_session 
        }.to change(GeographicArea, :count).by(1)
      end

      it "assigns a newly created geographic_area as @geographic_area" do
        post :create, {:geographic_area => valid_attributes}, valid_session
        expect(assigns(:geographic_area)).to be_a(GeographicArea)
        expect(assigns(:geographic_area)).to be_persisted
      end

      it "redirects to the created geographic_area" do
        post :create, {:geographic_area => valid_attributes}, valid_session
        expect(response).to redirect_to(GeographicArea.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved geographic_area as @geographic_area" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(GeographicArea).to receive(:save).and_return(false)
        post :create, {:geographic_area => {"name" => "invalid value"}}, valid_session
        expect(assigns(:geographic_area)).to be_a_new(GeographicArea)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(GeographicArea).to receive(:save).and_return(false)
        post :create, {:geographic_area => {"name" => "invalid value"}}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        # Assuming there are no other geographic_areas in the database, this
        # specifies that the GeographicArea created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(GeographicArea).to receive(:update).with({"name" => "MyString"})
        put :update, {:id => geographic_area.to_param, :geographic_area => {"name" => "MyString"}}, valid_session
      end

      it "assigns the requested geographic_area as @geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        put :update, {:id => geographic_area.to_param, :geographic_area => valid_attributes}, valid_session
        expect(assigns(:geographic_area)).to eq(geographic_area)
      end

      it "redirects to the geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        put :update, {:id => geographic_area.to_param, :geographic_area => valid_attributes}, valid_session
        expect(response).to redirect_to(geographic_area)
      end
    end

    describe "with invalid params" do
      it "assigns the geographic_area as @geographic_area" do
        geographic_area = GeographicArea.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(GeographicArea).to receive(:save).and_return(false)
        put :update, {:id => geographic_area.to_param, :geographic_area => {"name" => "invalid value"}}, valid_session
        expect(assigns(:geographic_area)).to eq(geographic_area)
      end

      it "re-renders the 'edit' template" do
        geographic_area = GeographicArea.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(GeographicArea).to receive(:save).and_return(false)
        put :update, {:id => geographic_area.to_param, :geographic_area => {"name" => "invalid value"}}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested geographic_area" do
      geographic_area = GeographicArea.create! valid_attributes
      expect {
        delete :destroy, {:id => geographic_area.to_param}, valid_session
      }.to change(GeographicArea, :count).by(-1)
    end

    it "redirects to the geographic_areas list" do
      geographic_area = GeographicArea.create! valid_attributes
      delete :destroy, {:id => geographic_area.to_param}, valid_session
      expect(response).to redirect_to(geographic_areas_url)
    end
  end

end
