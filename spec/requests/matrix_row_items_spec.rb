require 'rails_helper'

RSpec.describe "MatrixRowItems", type: :request do
  describe "GET /matrix_row_items" do
    it "works! (now write some real specs)" do
      get matrix_row_items_path
      expect(response).to have_http_status(200)
    end
  end
end
