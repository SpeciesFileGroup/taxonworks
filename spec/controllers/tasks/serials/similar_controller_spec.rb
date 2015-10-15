require 'rails_helper'

describe Tasks::Serials::SimilarController, type: :controller do

  before(:each) {
    sign_in
  }

  describe "GET like" do
    let(:s) {FactoryGirl.create(:valid_serial) }
    it "returns http success" do
      get :like, {id: s.id }
      expect(response).to render_template("like") 
    end
  end

end
