require 'rails_helper'

describe 'Api::V1::CollectingEvents', type: :request do

  include_context 'api context'

  context 'invalid date params' do
    specify 'returns bad_request for invalid start_date' do
      get '/api/v1/collecting_events', headers: headers, params: { project_id: project.id, start_date: '2020', end_date: '2020-06-30' }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to match(/start_date/)
    end
  end

end
