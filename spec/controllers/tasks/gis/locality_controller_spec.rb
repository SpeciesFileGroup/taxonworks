require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Tasks::Gis::LocalityController, type: :controller, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  # before(:all) {
  #   # GeoBuild.generate_ce_test_objects(1, 1)
  # }

  before(:each) {
    sign_in
  }

  # after(:all) {
  #   # GeoBuild.clean_slate_geo
  # }

  describe 'GET nearby' do
    let(:ce_a) { CollectingEvent.where(verbatim_label: 'Eh?').first }
    it 'returns http success' do
      # pending 'proper specification of the route'
      get :nearby, params: {id: ce_a.id, nearby_distance: '8'}
      expect(response).to have_http_status(:success)
    end
  end

end
