# require 'rails_helper'
#
# describe Tasks::CollectionObjects::AreaAndDateController, type: :controller, group: [:geo, :collecting_event] do
#   # include DataControllerConfiguration::ProjectDataControllerConfiguration
#
#   before(:all) {
#     # sign_in
#     generate_political_areas_with_collecting_events
#   }
#   before(:each) {
# sign_in
#   }
#   after(:all) { clean_slate_geo }
#
#   describe 'GET #index' do
#     it 'returns http success' do
#       get(:index)
#       expect(response).to have_http_status(:success)
#     end
#   end
#
#   describe '#set_date' do
#     it 'renders count of collection objects based on the start and end dates' do
#       get(:set_date, {search_start_date: Date.parse('1971/01/01').to_s.gsub('-', '/'), search_end_date: Date.parse('1980/12/31').to_s.gsub('-', '/')})
#       expect(response).to have_http_status(:success)
#       expect(JSON.parse(response.body)['html']).to eq('10')
#     end
#   end
#
#   describe '#find' do
#     let!(:params) {
#       {search_start_date: '1971/01/01',
#        search_end_date:   '1980/12/31',
#        drawn_area_shape:  GeographicArea
#                             .where(name: 'West Boxia')
#                             .first
#                             .default_geographic_item
#                             .to_geo_json_feature}
#     }
#     it 'renders dwca of the selected collection objects, and geo_json feature collection' do
#
#       xhr(:get, :find, params)
#       expect(response).to have_http_status(:success)
#     end
#   end
# end
