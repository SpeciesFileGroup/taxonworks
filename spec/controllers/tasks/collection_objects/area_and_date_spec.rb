require 'rails_helper'

describe Tasks::CollectionObjects::AreaAndDateController, type: :controller do
  # include DataControllerConfiguration::ProjectDataControllerConfiguration

  before(:all) {
    # sign_in
    generate_political_areas_with_collecting_events
  }
  after(:all) { clean_slate_geo }

  xdescribe 'GET #index' do
    it 'returns http success' do
      get(:index)
      expect(response).to have_http_status(:success)
    end
  end
end
