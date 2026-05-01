require 'rails_helper'

RSpec.describe Tasks::FieldOccurrences::InaturalistImportController, type: :controller do
  include ActiveJob::TestHelper

  before { sign_in }

  let(:uuid_found)   { '550e8400-e29b-41d4-a716-446655440001' }
  let(:uuid_missing) { '550e8400-e29b-41d4-a716-446655440002' }

  let(:mock_results) {
    [
      {
        'id' => '100', 'uuid' => uuid_found,
        'taxon' => { 'name' => 'Aus bus' }, 'community_taxon' => { 'name' => 'Aus bus' },
        'user' => { 'name' => 'Jane Doe', 'login' => 'janedoe', 'id' => 42, 'orcid' => nil },
        'observed_on' => '2023-06-15',
        'observed_on_details' => { 'year' => 2023, 'month' => 6, 'day' => 15, 'hour' => nil },
        'place_guess' => 'Some Forest', 'obscured' => false, 'geojson' => nil,
        'observation_photos' => [], 'observation_sounds' => [], 'annotations' => [],
        'identifications' => [], 'description' => nil,
      },
      {
        'id' => '200', 'uuid' => uuid_missing,
        'taxon' => { 'name' => 'Cus dus' }, 'community_taxon' => { 'name' => 'Cus dus' },
        'user' => { 'name' => 'Bob', 'login' => 'bob', 'id' => 99, 'orcid' => nil },
        'observed_on' => '2023-07-01',
        'observed_on_details' => { 'year' => 2023, 'month' => 7, 'day' => 1, 'hour' => nil },
        'place_guess' => 'Other Place', 'obscured' => false, 'geojson' => nil,
        'observation_photos' => [], 'observation_sounds' => [], 'annotations' => [],
        'identifications' => [], 'description' => nil,
      }
    ]
  }

  before do
    allow(Vendor::Nasturtium).to receive(:by_observation_ids).and_return(mock_results)
  end

  let!(:existing_fo) {
    otu = Otu.create!(name: 'Aus bus')
    ce = CollectingEvent.new(verbatim_date: '2023-06-15')
    ce.save!
    fo = FieldOccurrence.create!(total: 1, collecting_event: ce,
      taxon_determinations_attributes: [{ otu_id: otu.id }])
    Identifier::Global::Uuid::InaturalistObservation.create!(identifier_object: fo, identifier: uuid_found)
    fo
  }

  describe 'POST #submit with find_only: true' do
    def do_submit(**extra)
      post :submit, format: :json, params: { observation_ids: ['100', '200'], find_only: true, **extra }
    end

    specify 'returns found for an observation that exists in the project' do
      do_submit
      row = response.parsed_body['summary'].find { |r| r['observation_id'] == '100' }
      expect(row['status']).to eq('found')
    end

    specify 'found row includes browse_url' do
      do_submit
      row = response.parsed_body['summary'].find { |r| r['observation_id'] == '100' }
      expect(row['browse_url']).to be_present
    end

    specify 'returns not_imported for an observation not in the project' do
      do_submit
      row = response.parsed_body['summary'].find { |r| r['observation_id'] == '200' }
      expect(row['status']).to eq('not_imported')
    end

    specify 'found row returns real image and sound counts from the FO' do
      do_submit
      row = response.parsed_body['summary'].find { |r| r['observation_id'] == '100' }
      expect(row['image_count']).to eq(0)
      expect(row['sound_count']).to eq(0)
    end

    specify 'not_imported row has nil image and sound counts' do
      do_submit
      row = response.parsed_body['summary'].find { |r| r['observation_id'] == '200' }
      expect(row['image_count']).to be_nil
      expect(row['sound_count']).to be_nil
    end

    specify 'does not enqueue an import job' do
      expect { do_submit }.not_to have_enqueued_job(InaturalistImportJob)
    end

    specify 'found row has a non-blank taxon_name from otu_tag' do
      do_submit
      row = response.parsed_body['summary'].find { |r| r['observation_id'] == '100' }
      expect(row['taxon_name']).to be_present
    end
  end

  describe 'GET #recent' do
    specify 'clamps per_page to 100' do
      get :recent, format: :json, params: { per_page: 9999 }
      expect(response.headers['Pagination-Per-Page'].to_i).to eq(100)
    end

    specify 'defaults to 10 per page' do
      get :recent, format: :json
      expect(response.headers['Pagination-Per-Page'].to_i).to eq(10)
    end
  end
end
