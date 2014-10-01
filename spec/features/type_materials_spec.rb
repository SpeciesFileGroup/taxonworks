require 'rails_helper'

RSpec.describe "TypeMaterials", :type => :request do
  describe "GET /type_materials" do
    it "works! (now write some real specs)" do
      get type_materials_path
      expect(response).to have_http_status(200)
    end
  end
end
