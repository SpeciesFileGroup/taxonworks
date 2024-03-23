require 'rails_helper'

describe CollectingEvent, type: :model, group: [:geo, :collecting_events] do
  let(:collecting_event) { CollectingEvent.new }
  let(:county) { FactoryBot.create(:valid_geographic_area_stack) }
  let(:state) { county.parent }
  let(:country) { state.parent }

  context '.batch_update' do
    specify 'can update a verbatim field' do
      c1 =  FactoryBot.create(:valid_collecting_event)
      c2 = FactoryBot.create(:valid_collecting_event)
      l = 'The final frontier (psychiatrist).'

      params = {
        async_cutoff: 3,
        collecting_event: { verbatim_locality: l },
      }.merge( collecting_event_query: { collecting_event_id: [c1.id] })

      response = CollectingEvent.batch_update(params).to_json

      expect(response[:updated]).to include(c1.id)
      expect(response[:not_updated]).to eq([])
      expect(c1.reload.verbatim_locality).to eq(l)
    end

    context 'updating collector roles' do
      let(:c1) { FactoryBot.create(:valid_collecting_event) }

      specify 'can add the first collector' do
        collector = FactoryBot.create(:valid_person)
        params = { collecting_event: { roles_attributes:
                                         [{ person_id: collector.id, type: 'Collector' }] },
                   collecting_event_query: { collecting_event_id: [c1.id] }
        }

        response = CollectingEvent.batch_update(params).to_json

        expect(response[:updated]).to include(c1.id)
        expect(response[:not_updated]).to eq([])
        expect(c1.reload.collectors.count).to eq(1)
        expect(c1.collectors.first.id).to eq(collector.id)
      end

      specify 'can append a second collector' do
        first_collector = FactoryBot.create(:valid_person)
        c1.collectors << first_collector
        second_collector = FactoryBot.create(:valid_person)

        params = { collecting_event: { roles_attributes:
                                         [{ person_id: second_collector.id, type: 'Collector' }] },
                   collecting_event_query: { collecting_event_id: [c1.id] }
        }

        response = CollectingEvent.batch_update(params).to_json

        expect(response[:updated]).to include(c1.id)
        expect(response[:not_updated]).to eq([])
        expect(c1.reload.collectors.count).to eq(2)
        expect(c1.collectors.first.id).to eq(first_collector.id)
        expect(c1.collectors.second.id).to eq(second_collector.id)
      end

      specify 'can append multiple collectors' do
        first_collector = FactoryBot.create(:valid_person)
        c1.collectors << first_collector
        second_collector = FactoryBot.create(:valid_person)
        third_collector = FactoryBot.create(:valid_person)

        params = { collecting_event: { roles_attributes:
                                         [{ person_id: second_collector.id, type: 'Collector' },
                                          { person_id: third_collector.id, type: 'Collector' }] },
                   collecting_event_query: { collecting_event_id: [c1.id] }
        }

        response = CollectingEvent.batch_update(params).to_json

        expect(response[:updated]).to include(c1.id)
        expect(response[:not_updated]).to eq([])
        expect(c1.reload.collectors.count).to eq(3)
        expect(c1.collectors.first.id).to eq(first_collector.id)
        expect(c1.collectors.second.id).to eq(second_collector.id)
        expect(c1.collectors.third.id).to eq(third_collector.id)
      end
    end
  end


  context 'validation' do
    context 'time start/end' do
      specify 'if time_start_minute provided time_start_hour_required' do
        collecting_event.time_start_minute = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_start_hour)).to be_truthy
      end

      specify 'if time_start_second provided time_start_minute_required' do
        collecting_event.time_start_second = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_start_minute)).to be_truthy
      end

      specify 'if time_end_minute provided time_end_hour_required' do
        collecting_event.time_end_minute = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_end_hour)).to be_truthy
      end

      specify 'if time_end_second provided time_end_minute_required' do
        collecting_event.time_end_second = '44'
        collecting_event.valid?
        expect(collecting_event.errors.include?(:time_end_minute)).to be_truthy
      end
    end

    specify 'if verbatim_geolocation_uncertainty is provided, then so too are verbatim_longitude and verbatim_latitude' do
      collecting_event.verbatim_geolocation_uncertainty = 'based on my astrolab'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_geolocation_uncertainty)).to be_truthy
    end

    specify 'corresponding verbatim_latitude value is provided' do
      collecting_event.verbatim_latitude = '12.345'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_longitude)).to be_truthy
    end

    specify 'corresponding verbatim_longitude value is provided' do
      collecting_event.verbatim_longitude = '12.345'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_latitude)).to be_truthy
    end

    specify 'maximum elevation is greater than minimum elevation when both provided' do
      message                            = 'Maximum elevation is lower than minimum elevation.'
      collecting_event.minimum_elevation = 2
      collecting_event.maximum_elevation = 1
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors[:maximum_elevation].include?(message)).to be_truthy
    end

    specify 'md5_of_verbatim_collecting_event is unique within project' do
      label = "Label\nAnother line\nYet another line."
      c1 = FactoryBot.create(:valid_collecting_event, verbatim_label: label)
      c2 = FactoryBot.build(:valid_collecting_event, verbatim_label: label)
      expect(c2.valid?).to be_falsey
      expect(c2.errors[:md5_of_verbatim_label].count).to eq(1)
    end

    specify 'md5_of_verbatim_collecting_event is unique on update 1' do
      label = "SOUTH AFRICA: WCape Prov.\n" +
        "De Hoop Nat. Res.\n"	+
        "S34°27.150' E20°25.486'  19.6 m\n" +
        "11-XII-2004 a 04-22\n" +
        'col. J.N. Zahniser  sweep'

      c1 = CollectingEvent.create!(verbatim_label: label)
      label.gsub!(/\sa\s/, ' # ')
      c1.update(verbatim_label: label)
      expect(c1.errors[:base]).to eq([])
    end

    specify 'different multi-line labels' do
      l1 = "Lee, N.H.\n" +
        "VI-17-1953\n" +
        "\n" +
        "R.L.Blickle\n" +
        'Collr.'

      l2 = "Lee, N.H.\n" +
        'VI-17-1953'

      c1 = CollectingEvent.create!(verbatim_label: l1)
      c2 = CollectingEvent.new(verbatim_label: l2)
      c2.valid?
      expect(c2.errors).to be_empty
    end
  end

  context 'soft validation' do
    specify 'at least some label is provided' do
      message = 'At least one label type, or field notes, should be provided.'
      collecting_event.soft_validate
      expect(collecting_event.soft_validations.messages_on(:base).include?(message)).to be_truthy
    end
  end

  context 'scopes' do
    let!(:ce1) { FactoryBot.create(:valid_collecting_event) }
    let!(:ce2) { FactoryBot.create(:valid_collecting_event) }
    let!(:ce3) { FactoryBot.create(:valid_collecting_event) }

    let!(:s1) { FactoryBot.create(:valid_specimen, collecting_event: ce1) }

    specify '.used_recently' do
      expect(CollectingEvent.used_recently).to contain_exactly(ce1)
    end

    specify '.used_in_project' do
      expect(CollectingEvent.used_in_project(s1.project_id)).to contain_exactly(ce1)
    end
  end

  context 'actions' do
    specify 'if a verbatim_label is present then a md5_of_verbatim_label is generated' do
      collecting_event.verbatim_label = "Label\nAnother line\nYet another line."
      expect(collecting_event.md5_of_verbatim_label.blank?).to be_falsey
    end
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'geographic_area' do
        expect(collecting_event.geographic_area = GeographicArea.new()).to be_truthy
      end
    end
    context 'has_many' do
      specify 'collection_objects' do
        expect(collecting_event.collection_objects << CollectionObject.new).to be_truthy
      end

      specify 'georeferences' do
        expect(collecting_event.georeferences << Georeference.new).to be_truthy
      end

      specify 'geographic_items' do
        expect(collecting_event.geographic_items << GeographicItem.new).to be_truthy
      end
    end
  end

  context 'fuzzy matching' do
    before {
      @c1 = FactoryBot.create(:valid_collecting_event, verbatim_locality: 'This is a base string.')
      @c2 = FactoryBot.create(:valid_collecting_event, verbatim_locality: 'This is a base string.')

      @c3 = FactoryBot.create(:valid_collecting_event, verbatim_locality: 'This is a roof string.')
      @c4 = FactoryBot.create(:valid_collecting_event, verbatim_locality: 'This is a r00f string.')
    }

    specify 'nearest_by_levenshtein(compared_string = nil, column = "verbatim_locality", limit = 10)' do
      expect(@c1.nearest_by_levenshtein(@c1.verbatim_locality).first).to eq(@c2)
      expect(@c2.nearest_by_levenshtein(@c2.verbatim_locality).first).to eq(@c1)
      expect(@c3.nearest_by_levenshtein(@c3.verbatim_locality).first).to eq(@c4)
      expect(@c4.nearest_by_levenshtein(@c4.verbatim_locality).first).to eq(@c3)
    end
  end

  specify '#time_start pads' do
    collecting_event.time_start_hour   = 4
    collecting_event.time_start_minute = 2
    collecting_event.time_start_second = 1
    expect(collecting_event.time_start).to eq('04:02:01')
  end

  specify '#time_end pads' do
    collecting_event.time_end_hour   = 4
    collecting_event.time_end_minute = 2
    collecting_event.time_end_second = 1
    expect(collecting_event.time_end).to eq('04:02:01')
  end

  specify 'labels are not trimmed' do
    s = ' asdf sd   asdfd '
    collecting_event.document_label = s
    collecting_event.valid?
    expect(collecting_event.document_label).to eq(s)
  end

  context '#clone' do
    before do
      collecting_event.update(
        verbatim_label: 'my label',
        collector_roles_attributes: [{person: FactoryBot.create(:valid_person) }]
      )
    end

    specify 'clones collectors' do
      a = collecting_event.clone
      expect(a.collectors.count).to eq(1)
    end

    specify 'clones georeferences' do
      FactoryBot.create(:valid_georeference_verbatim_data, collecting_event:)
      a = collecting_event.clone
      expect(a.georeferences.count).to eq(1)
    end
  end

  context 'roles' do
    specify '#collector_names 1' do
      collecting_event.verbatim_collectors = 'Smith & Jones'
      expect(collecting_event.collector_names).to eq('Smith & Jones')
    end

    specify '#collector_names 2' do
      a = FactoryBot.create(:valid_person, last_name: 'Smith')
      collecting_event.collectors << a
      expect(collecting_event.collector_names).to eq(a.last_name)
    end
  end

  context '#dwc_occurrences', group: :darwin_core do
    let!(:ce) { CollectingEvent.create!(start_date_year: 2010) }
    let!(:s) { Specimen.create!(collecting_event: ce) }

    specify 'dwc_occurrence_persisted?' do
      expect(s.dwc_occurrence_persisted?).to be_truthy
    end

    specify 'updating ce updates dwc_occurrence' do
      ce.update!(start_date_year: 2012)
      expect(s.dwc_occurrence.reload.eventDate).to match('2012')
    end

    specify 'does not update with no_dwc_occurrence_index: true' do
      ce.update!(start_date_year: 2012, no_dwc_occurrence: true)
      expect(s.dwc_occurrence.eventDate).to match('2010')
    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'data_attributes'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
    it_behaves_like 'documentation'
  end

end
