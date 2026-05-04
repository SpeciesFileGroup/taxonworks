require 'rails_helper'

describe Vendor::Nasturtium, type: :model, group: [:field_occurrences] do

  # Minimal iNat result hash used across multiple contexts.
  let(:result) {
    {
      'uuid'             => 'abc-123',
      'observed_on_string' => '2023-06-15',
      'observed_on_details' => { 'year' => 2023, 'month' => 6, 'day' => 15, 'hour' => 10 },
      'time_observed_at' => nil,
      'obscured'         => false,
      'place_guess'      => 'Some Forest',
      'geojson'          => { 'coordinates' => [-88.0, 41.0], 'type' => 'Point' },
      'positional_accuracy' => 50,
      'taxon'            => { 'name' => 'Aus bus' },
      'community_taxon'  => { 'name' => 'Aus bus' },
      'user'             => { 'name' => 'Jane Doe', 'login' => 'janedoe', 'orcid' => nil },
      'annotations'      => [],
      'observation_photos' => [],
      'observation_sounds' => [],
      'description'      => nil,
    }
  }

  describe 'INAT_LICENSE_CODE_TO_TW_LICENSE' do
    specify 'all values are keys in CREATIVE_COMMONS_LICENSES' do
      unknown = Vendor::Nasturtium::INAT_LICENSE_CODE_TO_TW_LICENSE.values -
        CREATIVE_COMMONS_LICENSES.keys
      expect(unknown).to be_empty
    end

    specify 'covers all inat_code entries in CREATIVE_COMMONS_LICENSES' do
      expected_codes = CREATIVE_COMMONS_LICENSES.values.filter_map { |v| v[:inat_code] }
      expect(Vendor::Nasturtium::INAT_LICENSE_CODE_TO_TW_LICENSE.keys).to match_array(expected_codes)
    end
  end

  describe '.observer_identification_uuid' do
    specify 'returns the uuid of the observer\'s current identification' do
      r = result.merge(
        'user' => result['user'].merge('id' => 42),
        'identifications' => [
          { 'uuid' => 'ident-uuid-1', 'user' => { 'id' => 42 }, 'current' => true },
          { 'uuid' => 'ident-uuid-2', 'user' => { 'id' => 99 }, 'current' => true },
        ]
      )
      expect(Vendor::Nasturtium.observer_identification_uuid(r)).to eq('ident-uuid-1')
    end

    specify 'returns nil when the observer has no current identification' do
      r = result.merge(
        'user' => result['user'].merge('id' => 42),
        'identifications' => [
          { 'uuid' => 'ident-uuid-1', 'user' => { 'id' => 42 }, 'current' => false },
        ]
      )
      expect(Vendor::Nasturtium.observer_identification_uuid(r)).to be_nil
    end

    specify 'returns nil when identifications are absent' do
      r = result.merge('user' => result['user'].merge('id' => 42))
      expect(Vendor::Nasturtium.observer_identification_uuid(r)).to be_nil
    end
  end

  describe '.stub_georeference' do
    specify 'returns nil when result is obscured' do
      expect(Vendor::Nasturtium.stub_georeference(result.merge('obscured' => true))).to be_nil
    end

    specify 'returns a georeference when not obscured and coordinates present' do
      expect(Vendor::Nasturtium.stub_georeference(result)).to be_a(Georeference::Inaturalist)
    end

    specify 'returns nil when coordinates are blank' do
      expect(Vendor::Nasturtium.stub_georeference(result.merge('geojson' => nil))).to be_nil
    end
  end

  describe '.stub_collecting_event' do
    specify 'sets verbatim_date from observed_on_string' do
      ce = Vendor::Nasturtium.stub_collecting_event(result)
      expect(ce.verbatim_date).to eq('2023-06-15')
    end

    specify 'sets start date parts from observed_on_details' do
      ce = Vendor::Nasturtium.stub_collecting_event(result)
      expect(ce.start_date_year).to eq(2023)
      expect(ce.start_date_month).to eq(6)
      expect(ce.start_date_day).to eq(15)
    end

    context 'when time_observed_at is present' do
      let(:result_with_time) { result.merge('time_observed_at' => '2023-06-15T14:32:45+00:00') }

      specify 'sets hour from time_observed_at' do
        ce = Vendor::Nasturtium.stub_collecting_event(result_with_time)
        expect(ce.time_start_hour).to eq(14)
      end

      specify 'sets minute from time_observed_at' do
        ce = Vendor::Nasturtium.stub_collecting_event(result_with_time)
        expect(ce.time_start_minute).to eq(32)
      end

      specify 'sets second from time_observed_at when non-zero' do
        ce = Vendor::Nasturtium.stub_collecting_event(result_with_time)
        expect(ce.time_start_second).to eq(45)
      end

      specify 'does not set second when zero' do
        ce = Vendor::Nasturtium.stub_collecting_event(result.merge('time_observed_at' => '2023-06-15T14:32:00+00:00'))
        expect(ce.time_start_second).to be_nil
      end
    end

    context 'when time_observed_at is absent' do
      specify 'falls back to hour from observed_on_details' do
        ce = Vendor::Nasturtium.stub_collecting_event(result)
        expect(ce.time_start_hour).to eq(10)
      end

      specify 'does not set minute' do
        ce = Vendor::Nasturtium.stub_collecting_event(result)
        expect(ce.time_start_minute).to be_nil
      end

      specify 'does not set hour when observed_on_details hour is nil' do
        r = result.merge('observed_on_details' => result['observed_on_details'].merge('hour' => nil))
        ce = Vendor::Nasturtium.stub_collecting_event(r)
        expect(ce.time_start_hour).to be_nil
      end
    end
  end

  describe '.person_by_orcid' do
    specify 'returns nil when user has no ORCID' do
      expect(Vendor::Nasturtium.person_by_orcid(result)).to be_nil
    end

    specify 'returns nil when no matching Person exists' do
      r = result.merge('user' => result['user'].merge('orcid' => '0000-0002-1825-0097'))
      expect(Vendor::Nasturtium.person_by_orcid(r)).to be_nil
    end

    context 'when a matching Person exists' do
      let(:person) { FactoryBot.create(:valid_person) }
      let(:orcid_url) { 'https://orcid.org/0000-0002-1825-0097' }

      before do
        Identifier::Global::Orcid.create!(
          identifier_object: person,
          identifier: orcid_url,
        )
      end

      specify 'finds by full ORCID URL' do
        r = result.merge('user' => result['user'].merge('orcid' => orcid_url))
        expect(Vendor::Nasturtium.person_by_orcid(r)&.id).to eq(person.id)
      end

      specify 'normalises bare ORCID ID to URL form' do
        r = result.merge('user' => result['user'].merge('orcid' => '0000-0002-1825-0097'))
        expect(Vendor::Nasturtium.person_by_orcid(r)&.id).to eq(person.id)
      end
    end
  end

  describe '.stub_observer_person' do
    specify 'returns Person::Unvetted with first/last split from user name when no ORCID' do
      p = Vendor::Nasturtium.stub_observer_person(result)
      expect(p).to be_a(Person::Unvetted)
      expect(p.first_name).to eq('Jane')
      expect(p.last_name).to eq('Doe')
    end

    specify 'falls back to login when name is blank, keeping it in last_name' do
      r = result.merge('user' => result['user'].merge('name' => nil))
      p = Vendor::Nasturtium.stub_observer_person(r)
      expect(p.first_name).to be_nil
      expect(p.last_name).to eq('janedoe')
    end

    context 'when ORCID matches an existing Person' do
      let(:person) { FactoryBot.create(:valid_person) }

      before do
        Identifier::Global::Orcid.create!(
          identifier_object: person,
          identifier: 'https://orcid.org/0000-0002-1825-0097',
        )
      end

      specify 'returns the matched Person' do
        r = result.merge('user' => result['user'].merge('orcid' => '0000-0002-1825-0097'))
        expect(Vendor::Nasturtium.stub_observer_person(r)&.id).to eq(person.id)
      end
    end
  end

  describe '.stub_otu' do
    specify 'uses community_taxon name when use_community_taxon is true' do
      r = result.merge('community_taxon' => { 'name' => 'Community taxon' }, 'taxon' => { 'name' => 'Observer taxon' })
      otu = Vendor::Nasturtium.stub_otu(r, project_id: Current.project_id, use_community_taxon: true)
      expect(otu.name).to eq('Community taxon')
    end

    specify 'falls back to taxon when community_taxon is nil' do
      r = result.merge('community_taxon' => nil)
      otu = Vendor::Nasturtium.stub_otu(r, project_id: Current.project_id, use_community_taxon: true)
      expect(otu.name).to eq('Aus bus')
    end

    specify 'uses taxon name when use_community_taxon is false' do
      r = result.merge('community_taxon' => { 'name' => 'Community taxon' }, 'taxon' => { 'name' => 'Observer taxon' })
      otu = Vendor::Nasturtium.stub_otu(r, project_id: Current.project_id, use_community_taxon: false)
      expect(otu.name).to eq('Observer taxon')
    end

    specify 'returns nil when taxon name is blank' do
      expect(Vendor::Nasturtium.stub_otu(result.merge('taxon' => nil, 'community_taxon' => nil), project_id: Current.project_id)).to be_nil
    end

    context 'with match_by_name: true' do
      let(:taxon_name) { FactoryBot.create(:valid_protonym).tap { |t| t.update_columns(cached: 'Aus bus') } }
      let!(:otu_with_taxon_name) { Otu.create!(taxon_name: taxon_name) }
      let!(:otu_name_only) { Otu.create!(name: 'Aus bus') }

      specify 'prefers OTU linked to a matching TaxonName' do
        found = Vendor::Nasturtium.stub_otu(result, project_id: Current.project_id, match_by_name: true)
        expect(found).to eq(otu_with_taxon_name)
      end

      specify 'falls back to OTU with matching name field when no TaxonName match' do
        otu_with_taxon_name.destroy
        found = Vendor::Nasturtium.stub_otu(result, project_id: Current.project_id, match_by_name: true)
        expect(found).to eq(otu_name_only)
      end

      specify 'builds a new name-only OTU when no match found' do
        otu_with_taxon_name.destroy
        otu_name_only.destroy
        found = Vendor::Nasturtium.stub_otu(result, project_id: Current.project_id, match_by_name: true)
        expect(found).to be_new_record
        expect(found.name).to eq('Aus bus')
      end
    end
  end

  describe '.permitted_photos' do
    specify 'returns photos with importable CC licenses' do
      r = result.merge('observation_photos' => [
        { 'photo' => { 'uuid' => 'p1', 'license_code' => 'cc-by', 'url' => 'http://example.com/square.jpg' } },
        { 'photo' => { 'uuid' => 'p2', 'license_code' => 'arr', 'url' => 'http://example.com/square2.jpg' } },
        { 'photo' => { 'uuid' => 'p3', 'license_code' => nil, 'url' => 'http://example.com/square3.jpg' } },
      ])
      obs_photos = Vendor::Nasturtium.permitted_photos(r)
      expect(obs_photos.map { |op| op['photo']['uuid'] }).to eq(['p1'])
    end

    specify 'returns empty array when observation_photos is absent' do
      expect(Vendor::Nasturtium.permitted_photos(result)).to eq([])
    end
  end

  describe '.permitted_sounds' do
    specify 'returns observation_sounds with importable CC licenses' do
      r = result.merge('observation_sounds' => [
        { 'uuid' => 's1', 'sound' => { 'license_code' => 'cc0', 'file_url' => 'http://example.com/sound.mp3' } },
        { 'uuid' => 's2', 'sound' => { 'license_code' => 'arr', 'file_url' => 'http://example.com/sound2.mp3' } },
        { 'uuid' => 's3', 'sound' => { 'license_code' => nil,   'file_url' => 'http://example.com/sound3.mp3' } },
      ])
      sounds = Vendor::Nasturtium.permitted_sounds(r)
      expect(sounds.map { |s| s['uuid'] }).to eq(['s1'])
    end

    specify 'returns empty array when observation_sounds is absent' do
      expect(Vendor::Nasturtium.permitted_sounds(result)).to eq([])
    end
  end

  describe '.stub_biocuration_classes' do
    let(:sex_group) { FactoryBot.create(:valid_biocuration_group, uri: 'http://rs.tdwg.org/dwc/terms/sex') }
    let(:female_class) { FactoryBot.create(:valid_biocuration_class, name: 'Female') }

    before { Tag.create!(tag_object: female_class, keyword: sex_group) }

    specify 'returns matching BiocurationClass for a known annotation' do
      r = result.merge('annotations' => [
        { 'controlled_attribute' => { 'label' => 'Sex' }, 'controlled_value' => { 'label' => 'Female' } }
      ])
      expect(Vendor::Nasturtium.stub_biocuration_classes(r, project_id: Current.project_id))
        .to include(female_class)
    end

    specify 'skips annotations with no DwC mapping' do
      r = result.merge('annotations' => [
        { 'controlled_attribute' => { 'label' => 'Alive or Dead' }, 'controlled_value' => { 'label' => 'Alive' } }
      ])
      expect(Vendor::Nasturtium.stub_biocuration_classes(r, project_id: Current.project_id)).to be_empty
    end

    specify 'skips annotations whose value has no matching BiocurationClass in project' do
      r = result.merge('annotations' => [
        { 'controlled_attribute' => { 'label' => 'Sex' }, 'controlled_value' => { 'label' => 'Male' } }
      ])
      expect(Vendor::Nasturtium.stub_biocuration_classes(r, project_id: Current.project_id)).to be_empty
    end

    specify 'returns empty array when annotations are absent' do
      expect(Vendor::Nasturtium.stub_biocuration_classes(result, project_id: Current.project_id)).to be_empty
    end
  end

  describe '.build_image!' do
    let(:photo_uuid) { '550e8400-e29b-41d4-a716-446655440010' }
    let(:obs_photo) {
      {
        'uuid' => photo_uuid,
        'photo' => {
          'license_code' => 'cc-by',
          'url' => 'http://example.com/square.jpg',
          'attribution' => '(c) janedoe, some rights reserved (CC BY)',
          'original_filename' => nil,
          'file_content_type' => 'image/png'
        }
      }
    }

    let(:image_tempfile) {
      t = Tempfile.new(['test', '.png'], binmode: true)
      t.write(File.binread(Rails.root.join('spec/files/images/tiny.png')))
      t.rewind
      t.define_singleton_method(:original_filename) { 'tiny.png' }
      t
    }

    before do
      allow(Vendor::Nasturtium).to receive(:download_to_tempfile).and_return(image_tempfile)
      allow(Vendor::Nasturtium).to receive(:stub_copyright_person).and_return(FactoryBot.create(:valid_person))
    end

    specify 'attaches an InaturalistObservationPhoto identifier with the obs_photo uuid' do
      image = Vendor::Nasturtium.build_image!(obs_photo, result:, observed_year: 2023)
      ident = image.identifiers.find { |i| i.is_a?(Identifier::Global::Uuid::InaturalistObservationPhoto) }
      expect(ident&.identifier).to eq(photo_uuid)
    end
  end

  describe '.build_sound!' do
    let(:sound_uuid) { '550e8400-e29b-41d4-a716-446655440011' }
    let(:obs_sound) {
      {
        'uuid' => sound_uuid,
        'sound' => {
          'license_code' => 'cc-by',
          'file_url' => 'http://example.com/sound.wav',
          'attribution' => '(c) janedoe, some rights reserved (CC BY)',
          'original_filename' => nil,
          'file_content_type' => 'audio/wav'
        }
      }
    }

    let(:sound_tempfile) {
      t = Tempfile.new(['test', '.wav'], binmode: true)
      t.write(File.binread(Rails.root.join('spec/files/sounds/sound1.wav')))
      t.rewind
      t.define_singleton_method(:original_filename) { 'sound1.wav' }
      t
    }

    before do
      allow(Vendor::Nasturtium).to receive(:download_to_tempfile).and_return(sound_tempfile)
      allow(Vendor::Nasturtium).to receive(:stub_copyright_person).and_return(FactoryBot.create(:valid_person))
    end

    specify 'attaches an InaturalistObservationSound identifier with the obs_sound uuid' do
      sound = Vendor::Nasturtium.build_sound!(obs_sound, result:, observed_year: 2023)
      ident = sound.identifiers.find { |i| i.is_a?(Identifier::Global::Uuid::InaturalistObservationSound) }
      expect(ident&.identifier).to eq(sound_uuid)
    end
  end

end
