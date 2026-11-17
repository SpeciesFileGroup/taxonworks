require 'rails_helper'

RSpec.describe CollectingEventsController, type: :controller do
  render_views
  before { sign_in }

  let(:organization) { FactoryBot.create(:valid_organization) }
  let(:person) { FactoryBot.create(:valid_person) }
  let(:event) { FactoryBot.create(:valid_collecting_event) }

  it 'shows ordered collector roles with links to each person or organization' do
    event.collector_roles.create!(person:, position: 2)
    event.collector_roles.create!(organization:, position: 1)

    get :show, params: { id: event.id }

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    collectors = document.css('h3').find { |heading| heading.text == 'Collectors' }.next_element
    expect(collectors.css('li a').map { |link| link['href'] }).to eq(["/organizations/#{organization.id}", "/people/#{person.id}"])
  end

  it 'creates, serializes and updates mixed collectors without changing person fields' do
    post :create, params: {
      format: :json, extend: ['roles'],
      collecting_event: { verbatim_label: 'Organization expedition', roles_attributes: [
        { type: 'Collector', organization_id: organization.id, position: 1 },
        { type: 'Collector', person_id: person.id, position: 2 }
      ] }
    }
    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body['collector_roles'].first['organization']['name']).to eq(organization.name)
    expect(body['collector_roles'].last['person']['cached']).to eq(person.cached)
    created = CollectingEvent.find(body['id'])
    organization_role, person_role = created.collector_roles.order(:position)
    patch :update, params: { id: created.id, format: :json, extend: ['roles'], collecting_event: { roles_attributes: [
      { id: person_role.id, position: 1 }, { id: organization_role.id, position: 2 }
    ] } }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['collector_roles'].map { |r| r['id'] }).to eq([person_role.id, organization_role.id])
    patch :update, params: { id: created.id, format: :json, collecting_event: { roles_attributes: [{ id: organization_role.id, _destroy: true }] } }
    expect(created.reload.collector_roles.count).to eq(1)
  end

  it 'includes organizations in public JSON and preserves the brief person fields' do
    event.collector_roles.create!(organization: organization, position: 1)
    event.collector_roles.create!(person: person, position: 2)
    get :api_show, params: { id: event.id, format: :json, extend: ['roles'] }
    expect(response).to have_http_status(:ok)
    roles = JSON.parse(response.body)['collector_roles']
    expect(roles.first['organization']['id']).to eq(organization.id)
    expect(roles.last['person']).to include('id' => person.id, 'name' => person.cached, 'global_id' => Person.find(person.id).to_global_id.to_s)
  end

  it 'accepts organization collectors in batch preview and apply' do
    event
    payload = { format: :json, collecting_event_query: { collecting_event_id: [event.id] }, collecting_event: {
      roles_attributes: [{ type: 'Collector', organization_id: organization.id }]
    } }
    patch :batch_update, params: payload.merge(preview: true)
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['cap_reason']).to be_nil
    expect(event.reload.collector_roles).to be_empty
    patch :batch_update, params: payload
    expect(response).to have_http_status(:ok)
    expect(event.reload.collectors_organization).to include(organization)
  end
end
