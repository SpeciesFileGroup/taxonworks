require 'rails_helper'

RSpec.describe InaturalistImportJob, type: :model, group: :field_occurrences do

  let(:project_id) { Current.project_id }
  let(:user_id) { Current.user_id }

  let(:base_result) {
    {
      'id'                  => '99182856',
      'uuid'                => '550e8400-e29b-41d4-a716-446655440000',
      'observed_on_string'  => '2023-06-15',
      'observed_on_details' => { 'year' => 2023, 'month' => 6, 'day' => 15, 'hour' => nil },
      'time_observed_at'    => nil,
      'obscured'            => false,
      'place_guess'         => 'Some Forest',
      'geojson'             => nil,
      'positional_accuracy' => nil,
      'taxon'               => { 'name' => 'Aus bus' },
      'community_taxon'     => { 'name' => 'Aus bus' },
      'user'                => { 'id' => 42, 'name' => 'Jane Doe', 'login' => 'janedoe', 'orcid' => nil },
      'identifications'     => [],
      'annotations'         => [],
      'observation_photos'  => [],
      'observation_sounds'  => [],
      'description'         => nil,
    }
  }

  def perform(results: [base_result], **opts)
    InaturalistImportJob.new.perform(
      results:,
      project_id:,
      user_id:,
      **opts
    )
  end

  specify 'creates a FieldOccurrence for each result' do
    expect { perform }.to change(FieldOccurrence, :count).by(1)
  end

  specify 'attaches an InaturalistObservation identifier to the FieldOccurrence' do
    perform
    fo = FieldOccurrence.last
    expect(fo.identifiers.map(&:class)).to include(Identifier::Global::Uuid::InaturalistObservation)
  end

  specify 'creates a TaxonDetermination with the iNat taxon name' do
    perform
    expect(FieldOccurrence.last.taxon_determinations.first.otu.name).to eq('Aus bus')
  end

  context 'when the observation has coordinates' do
    let(:georeferenced_result) {
      base_result.merge(
        'geojson'             => { 'coordinates' => [-88.0, 41.0], 'type' => 'Point' },
        'positional_accuracy' => 10
      )
    }

    specify 'attaches the observer as georeferencer on the georeference' do
      perform(results: [georeferenced_result])
      georef = FieldOccurrence.last.collecting_event.georeferences.first
      expect(georef).to be_a(Georeference::Inaturalist)
      expect(georef.georeference_authors.map(&:last_name)).to include('Jane Doe')
    end
  end

  context 'when use_community_taxon is false' do
    let(:result_with_ident) {
      base_result.merge(
        'identifications' => [
          { 'uuid' => '661f9511-f30c-52e5-b827-557766551111', 'user' => { 'id' => 42 }, 'current' => true }
        ]
      )
    }

    specify 'attaches an InaturalistIdentification identifier to the TaxonDetermination' do
      perform(results: [result_with_ident], use_community_taxon: false)
      td = FieldOccurrence.last.taxon_determinations.first
      ident = td.identifiers.find { |i| i.is_a?(Identifier::Global::Uuid::InaturalistIdentification) }
      expect(ident&.identifier).to eq('661f9511-f30c-52e5-b827-557766551111')
    end

    specify 'does not attach an InaturalistIdentification when no current identification exists' do
      perform(results: [base_result], use_community_taxon: false)
      td = FieldOccurrence.last.taxon_determinations.first
      expect(td.identifiers.map(&:class)).not_to include(Identifier::Global::Uuid::InaturalistIdentification)
    end
  end

  context 'when use_community_taxon is true' do
    specify 'does not attach an InaturalistIdentification to the TaxonDetermination' do
      perform(use_community_taxon: true)
      td = FieldOccurrence.last.taxon_determinations.first
      expect(td.identifiers.map(&:class)).not_to include(Identifier::Global::Uuid::InaturalistIdentification)
    end
  end

  specify 'skips results with no taxon name and continues remaining imports' do
    no_taxon = base_result.merge('taxon' => nil, 'community_taxon' => nil, 'uuid' => '00000000-0000-0000-0000-000000000001')
    with_taxon = base_result.merge('uuid' => '00000000-0000-0000-0000-000000000002')
    expect { perform(results: [no_taxon, with_taxon]) }.to change(FieldOccurrence, :count).by(1)
  end

end
