require 'rails_helper'

RSpec.describe "DatasetRecords", type: :request do
  describe "GET /dataset_records" do
    it "works! (now write some real specs)" do
      get dataset_records_path
      expect(response).to have_http_status(200)
    end
  end
end
