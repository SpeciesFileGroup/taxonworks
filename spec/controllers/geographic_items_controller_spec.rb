require 'rails_helper'

describe GeographicItemsController, type: :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes( FactoryBot.build(:valid_geographic_item).attributes )
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GeographicItemsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET show' do
    it 'assigns the requested geographic_item as @geographic_item' do
      geographic_item = GeographicItem.create!(valid_attributes)

      get :show, params: {id: geographic_item.to_param}, session: valid_session
      expect(assigns(:geographic_item)).to eq(geographic_item.becomes(GeographicItem))
    end
  end

  describe 'GET edit' do
    it 'assigns the requested geographic_item as @geographic_item' do
      geographic_item = GeographicItem.create!(valid_attributes)
      get :edit, params: {id: geographic_item.to_param}, session: valid_session
      expect(assigns(:geographic_item)).to eq(geographic_item.becomes(GeographicItem))
    end
  end

# describe "PUT update" do
#   describe "with valid params" do
#     it "updates the requested geographic_item" do
#       geographic_item = GeographicItem.create!(valid_attributes)
#       # Assuming there are no other geographic_items in the database, this
#       # specifies that the GeographicItem created on the previous line
#       # receives the :update_attributes message with whatever params are
#       # submitted in the request.
#       expect_any_instance_of(GeographicItem).to receive(:update).with({'point' => ""})
#       put :update, params: {id: geographic_item.to_param, :geographic_item => {'point' => ""}}, session: valid_session
#     end

#     it "assigns the requested geographic_item as @geographic_item" do
#       geographic_item = GeographicItem.create!(valid_attributes)
#       put :update, params: {id: geographic_item.to_param, :geographic_item => valid_attributes}, session: valid_session
#       expect(assigns(:geographic_item)).to eq(geographic_item.becomes(GeographicItem::Point))
#     end

#     it "redirects to the geographic_item" do
#       geographic_item = GeographicItem.create!(valid_attributes)
#       put :update, params: {id: geographic_item.to_param, :geographic_item => valid_attributes}, session: valid_session
#       expect(response).to redirect_to(geographic_item)
#     end
#   end

#   describe "with invalid params" do
#     it "assigns the geographic_item as @geographic_item" do
#       geographic_item = GeographicItem.create!(valid_attributes)
#       # Trigger the behavior that occurs when invalid params are submitted
#       allow_any_instance_of(GeographicItem).to receive(:save).and_return(false)
#       put :update, params: {id: geographic_item.to_param, :geographic_item => {"point" => "invalid value"}}, session: valid_session
#       expect(assigns(:geographic_item)).to eq(geographic_item.becomes(GeographicItem::Point))
#     end

#     it "re-renders the 'edit' template" do
#       geographic_item = GeographicItem.create!(valid_attributes)
#       # Trigger the behavior that occurs when invalid params are submitted
#       allow_any_instance_of(GeographicItem).to receive(:save).and_return(false)
#       put :update, params: {id: geographic_item.to_param, :geographic_item => {"point" => "invalid value"}}, session: valid_session
#       expect(response).to render_template("edit")
#     end
#   end
# end

# describe "DELETE destroy" do
#   it "destroys the requested geographic_item" do
#     geographic_item = GeographicItem.create!(valid_attributes)
#     expect {
#       delete :destroy, params: {id: geographic_item.to_param}, session: valid_session
#     }.to change(GeographicItem, :count).by(-1)
#   end

#   it "redirects to the geographic_items list" do
#     geographic_item = GeographicItem.create!(valid_attributes)
#     delete :destroy, params: {id: geographic_item.to_param}, session: valid_session
#     expect(response).to redirect_to(geographic_items_url)
#   end
# end

end
