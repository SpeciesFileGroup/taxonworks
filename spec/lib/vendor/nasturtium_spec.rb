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

  describe '.parse_observation_ids' do
    specify 'parses bare integer IDs' do
      expect(Vendor::Nasturtium.parse_observation_ids("12345\n99182856")).to eq(['12345', '99182856'])
    end

    specify 'parses full iNat URLs' do
      expect(Vendor::Nasturtium.parse_observation_ids('https://www.inaturalist.org/observations/99182856'))
        .to eq(['99182856'])
    end

    specify 'skips blank lines' do
      expect(Vendor::Nasturtium.parse_observation_ids("12345\n\n67890")).to eq(['12345', '67890'])
    end

    specify 'skips non-matching lines' do
      expect(Vendor::Nasturtium.parse_observation_ids("not-an-id\n12345")).to eq(['12345'])
    end

    specify 'returns empty array for blank input' do
      expect(Vendor::Nasturtium.parse_observation_ids('')).to eq([])
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

  describe '.stub_determiner' do
    specify 'returns Person::Unvetted built from user name when no ORCID' do
      d = Vendor::Nasturtium.stub_determiner(result)
      expect(d).to be_a(Person::Unvetted)
      expect(d.last_name).to eq('Jane Doe')
    end

    specify 'falls back to login when name is blank' do
      r = result.merge('user' => result['user'].merge('name' => nil))
      d = Vendor::Nasturtium.stub_determiner(r)
      expect(d.last_name).to eq('janedoe')
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
        expect(Vendor::Nasturtium.stub_determiner(r)&.id).to eq(person.id)
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
      photos = Vendor::Nasturtium.permitted_photos(r)
      expect(photos.map { |p| p['uuid'] }).to eq(['p1'])
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

end
