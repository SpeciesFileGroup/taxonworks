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
      'user'             => { 'id' => 42, 'name' => 'Jane Doe', 'login' => 'janedoe', 'orcid' => nil },
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

    specify 'returns nil when positional_accuracy exceeds 10km' do
      expect(Vendor::Nasturtium.stub_georeference(result.merge('positional_accuracy' => 10_001))).to be_nil
    end

    specify 'returns a georeference when positional_accuracy is exactly at the limit' do
      expect(Vendor::Nasturtium.stub_georeference(result.merge('positional_accuracy' => 10_000))).to be_a(Georeference::Inaturalist)
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

    specify 'sets verbatim_collectors from user name' do
      ce = Vendor::Nasturtium.stub_collecting_event(result)
      expect(ce.verbatim_collectors).to eq('Jane Doe')
    end

    specify 'falls back to login for verbatim_collectors when name is blank' do
      r = result.merge('user' => result['user'].merge('name' => nil))
      ce = Vendor::Nasturtium.stub_collecting_event(r)
      expect(ce.verbatim_collectors).to eq('janedoe')
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

    specify 'builds a collector role from the observer, same as stub_collector' do
      ce = Vendor::Nasturtium.stub_collecting_event(result)
      expect(ce.collector_roles.first.person.last_name).to eq('Doe')
    end

    specify 'shares the person_cache with the collector role' do
      cache = {}
      ce = Vendor::Nasturtium.stub_collecting_event(result, person_cache: cache)
      observer = Vendor::Nasturtium.stub_observer_person(result, person_cache: cache)
      expect(ce.collector_roles.first.person).to equal(observer)
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

  describe '.parse_attribution_name' do
    specify 'extracts the name from a licensed attribution string' do
      a = '(c) Jane Doe, some rights reserved (CC BY-NC)'
      expect(Vendor::Nasturtium.parse_attribution_name(a)).to eq('Jane Doe')
    end

    specify 'extracts the name from an all-rights-reserved attribution string' do
      a = '(c) Jane Doe, all rights reserved'
      expect(Vendor::Nasturtium.parse_attribution_name(a)).to eq('Jane Doe')
    end

    specify 'does not truncate at a comma within the name itself' do
      a = '(c) Kim, Hyun-tae, some rights reserved (CC BY-NC-SA)'
      expect(Vendor::Nasturtium.parse_attribution_name(a)).to eq('Kim, Hyun-tae')
    end

    specify 'collapses stray double spaces' do
      a = '(c) Galen  Stewart, all rights reserved'
      expect(Vendor::Nasturtium.parse_attribution_name(a)).to eq('Galen Stewart')
    end

    specify 'returns nil for a CC0 attribution with no name' do
      expect(Vendor::Nasturtium.parse_attribution_name('no rights reserved')).to be_nil
    end

    specify 'returns nil when blank' do
      expect(Vendor::Nasturtium.parse_attribution_name(nil)).to be_nil
      expect(Vendor::Nasturtium.parse_attribution_name('')).to be_nil
    end
  end

  describe '.person_from_display_name' do
    specify 'splits a multi-word name via BibTeX' do
      p = Vendor::Nasturtium.person_from_display_name('Jane Doe')
      expect(p.first_name).to eq('Jane')
      expect(p.last_name).to eq('Doe')
    end

    specify 'puts a single-word name directly into last_name' do
      p = Vendor::Nasturtium.person_from_display_name('janedoe')
      expect(p.first_name).to be_nil
      expect(p.last_name).to eq('janedoe')
    end

    specify 'builds an "Undetermined iNaturalist user" placeholder when nil' do
      p = Vendor::Nasturtium.person_from_display_name(nil)
      expect(p.first_name).to be_nil
      expect(p.last_name).to eq('Undetermined iNaturalist user')
    end

    specify 'builds an "Undetermined iNaturalist user" placeholder when blank' do
      p = Vendor::Nasturtium.person_from_display_name('')
      expect(p.first_name).to be_nil
      expect(p.last_name).to eq('Undetermined iNaturalist user')
    end
  end

  describe '.stub_collector' do
    specify 'returns Person::Unvetted with first/last split from user name when no ORCID' do
      p = Vendor::Nasturtium.stub_collector(result)
      expect(p).to be_a(Person::Unvetted)
      expect(p.first_name).to eq('Jane')
      expect(p.last_name).to eq('Doe')
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
        expect(Vendor::Nasturtium.stub_collector(r)&.id).to eq(person.id)
      end
    end

    specify 'shares a person_cache with stub_observer_person for the same result' do
      cache = {}
      collector = Vendor::Nasturtium.stub_collector(result, person_cache: cache)
      observer  = Vendor::Nasturtium.stub_observer_person(result, person_cache: cache)
      expect(collector).to equal(observer)
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

    specify 'builds an "Undetermined iNaturalist user" placeholder when both name and login are blank' do
      r = result.merge('user' => result['user'].merge('name' => nil, 'login' => nil))
      p = Vendor::Nasturtium.stub_observer_person(r)
      expect(p.first_name).to be_nil
      expect(p.last_name).to eq('Undetermined iNaturalist user')
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

    context 'with a person_cache' do
      let(:cache) { {} }

      specify 'returns the same built Person instance on repeated calls for the same name' do
        first  = Vendor::Nasturtium.stub_observer_person(result, person_cache: cache)
        second = Vendor::Nasturtium.stub_observer_person(result, person_cache: cache)
        expect(second).to equal(first)
      end

      specify 'shares the cache with the copyright holder when the attribution names the observer' do
        r = result.merge('user' => result['user'].merge('id' => 42))
        observer = Vendor::Nasturtium.stub_observer_person(r, person_cache: cache)
        media = { 'attribution' => '(c) Jane Doe, some rights reserved (CC BY)' }
        copyright = Vendor::Nasturtium.stub_copyright_person(r, media:, person_cache: cache)
        expect(copyright).to equal(observer)
      end

      specify 'treats a nameless attribution (e.g. CC0) as the observer' do
        r = result.merge('user' => result['user'].merge('id' => 42))
        observer = Vendor::Nasturtium.stub_observer_person(r, person_cache: cache)
        media = { 'attribution' => 'no rights reserved' }
        copyright = Vendor::Nasturtium.stub_copyright_person(r, media:, person_cache: cache)
        expect(copyright).to equal(observer)
      end

      specify 'builds an "Undetermined iNaturalist user" placeholder when neither attribution nor the observer gives a name' do
        r = result.merge('user' => result['user'].merge('id' => 42, 'name' => nil, 'login' => nil))
        media = { 'attribution' => 'no rights reserved' }
        copyright = Vendor::Nasturtium.stub_copyright_person(r, media:, person_cache: cache)
        expect(copyright.first_name).to be_nil
        expect(copyright.last_name).to eq('Undetermined iNaturalist user')
      end

      specify 'rebuilds when the cached Person is no longer in the database' do
        first = Vendor::Nasturtium.stub_observer_person(result, person_cache: cache)
        first.save!
        first.destroy!
        second = Vendor::Nasturtium.stub_observer_person(result, person_cache: cache)
        expect(second).not_to equal(first)
        expect(second).to be_new_record
      end

      specify 'does not merge two different users who happen to share a display name' do
        a = result.merge('user' => result['user'].merge('id' => 1, 'name' => 'Jane Doe'))
        b = result.merge('user' => result['user'].merge('id' => 2, 'name' => 'Jane Doe'))
        first  = Vendor::Nasturtium.stub_observer_person(a, person_cache: cache)
        second = Vendor::Nasturtium.stub_observer_person(b, person_cache: cache)
        expect(second).not_to equal(first)
      end

      specify 'reuses the same Person across results for the same user id even if name differs' do
        a = result.merge('user' => result['user'].merge('id' => 1, 'name' => 'Jane Doe'))
        b = result.merge('user' => result['user'].merge('id' => 1, 'name' => 'J. Doe'))
        first  = Vendor::Nasturtium.stub_observer_person(a, person_cache: cache)
        second = Vendor::Nasturtium.stub_observer_person(b, person_cache: cache)
        expect(second).to equal(first)
      end

      specify 'does not merge into the observer when the attribution names someone else, even with an iNat user id' do
        r = result.merge('user' => result['user'].merge('id' => 42))
        observer = Vendor::Nasturtium.stub_observer_person(r, person_cache: cache)
        media = { 'attribution' => '(c) Someone Else, some rights reserved (CC BY)' }
        copyright = Vendor::Nasturtium.stub_copyright_person(r, media:, person_cache: cache)
        expect(copyright).not_to equal(observer)
      end

      specify 'reuses the same Person for repeated credits to the same non-observer name in one run' do
        media = { 'attribution' => '(c) Someone Else, some rights reserved (CC BY)' }
        first  = Vendor::Nasturtium.stub_copyright_person(result, media:, person_cache: cache)
        second = Vendor::Nasturtium.stub_copyright_person(result, media:, person_cache: cache)
        expect(second).to equal(first)
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

    before do
      allow(Vendor::Nasturtium).to receive(:download_to_tempfile) {
        t = Tempfile.new(['test', '.png'], binmode: true)
        t.write(File.binread(Rails.root.join('spec/files/images/tiny.png')))
        t.rewind
        t.define_singleton_method(:original_filename) { 'tiny.png' }
        t
      }
      allow(Vendor::Nasturtium).to receive(:stub_copyright_person).and_return(FactoryBot.create(:valid_person))
    end

    specify 'attaches an InaturalistObservationPhoto identifier with the obs_photo uuid' do
      image = Vendor::Nasturtium.build_image!(obs_photo, result:, observed_year: 2023)
      ident = image.identifiers.find { |i| i.is_a?(Identifier::Global::Uuid::InaturalistObservationPhoto) }
      expect(ident&.identifier).to eq(photo_uuid)
    end

    specify 'returns the existing image when the fingerprint is already in the database' do
      existing = Vendor::Nasturtium.build_image!(obs_photo, result:, observed_year: 2023)
      image = Vendor::Nasturtium.build_image!(obs_photo, result:, observed_year: 2023)
      expect(image.id).to eq(existing.id)
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

    before do
      allow(Vendor::Nasturtium).to receive(:download_to_tempfile) {
        t = Tempfile.new(['test', '.wav'], binmode: true)
        t.write(File.binread(Rails.root.join('spec/files/sounds/sound1.wav')))
        t.rewind
        t.define_singleton_method(:original_filename) { 'sound1.wav' }
        t
      }
      allow(Vendor::Nasturtium).to receive(:stub_copyright_person).and_return(FactoryBot.create(:valid_person))
    end

    specify 'attaches an InaturalistObservationSound identifier with the obs_sound uuid' do
      sound = Vendor::Nasturtium.build_sound!(obs_sound, result:, observed_year: 2023)
      ident = sound.identifiers.find { |i| i.is_a?(Identifier::Global::Uuid::InaturalistObservationSound) }
      expect(ident&.identifier).to eq(sound_uuid)
    end

    specify 'returns the existing sound when the identifier uuid is already in the database' do
      existing = Vendor::Nasturtium.build_sound!(obs_sound, result:, observed_year: 2023)
      sound = Vendor::Nasturtium.build_sound!(obs_sound, result:, observed_year: 2023)
      expect(sound.id).to eq(existing.id)
    end
  end

end
