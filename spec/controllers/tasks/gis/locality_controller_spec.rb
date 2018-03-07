require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Tasks::Gis::LocalityController, type: :controller, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'

  before(:each) {
    sign_in
    [ce_a, ce_b, gr_a, gr_b]
  }

  describe 'GET nearby' do
    it 'returns http success' do
      # pending 'proper specification of the route'
      get :nearby, params: {id: ce_a.id, nearby_distance: '8'}
      expect(response).to have_http_status(:success)
    end
  end

end
