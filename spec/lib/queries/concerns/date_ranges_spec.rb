require 'rails_helper'

describe 'Queries::Concerns::DateRanges', type: :model do

  let(:q) { Queries::CollectingEvent::Filter.new({}) }
  let(:q_api) { Queries::CollectingEvent::Filter.new({api: true}) }

  context '#valid_date_param?' do
    specify 'valid date' do
      expect(q.valid_date_param?('2020-06-15')).to be true
    end

    specify 'valid date with single digit month and day' do
      expect(q.valid_date_param?('2020-6-1')).to be true
    end

    specify 'invalid - year only' do
      expect(q.valid_date_param?('2020')).to be false
    end

    specify 'invalid - two digit year' do
      expect(q.valid_date_param?('20-01-01')).to be false
    end

    specify 'invalid - empty string' do
      expect(q.valid_date_param?('')).to be false
    end

    specify 'invalid - nil' do
      expect(q.valid_date_param?(nil)).to be false
    end
  end

  context '#set_date_params' do
    specify 'sets start_date when valid' do
      q.set_date_params(start_date: '2020-06-01', end_date: '2020-06-30')
      expect(q.start_date).to eq('2020-06-01')
    end

    specify 'ignores start_date when invalid' do
      q.set_date_params(start_date: 'not-a-date', end_date: '2020-06-30')
      expect(q.start_date).to be_nil
    end

    specify 'sets end_date when valid' do
      q.set_date_params(start_date: '2020-06-01', end_date: '2020-06-30')
      expect(q.end_date).to eq('2020-06-30')
    end

    specify 'ignores end_date when invalid' do
      q.set_date_params(start_date: '2020-06-01', end_date: '2020-13-01')
      expect(q.end_date).to be_nil
    end

    context 'api: true' do
      specify 'raises on invalid start_date' do
        expect { q_api.set_date_params(start_date: 'not-a-date', end_date: '2020-06-30') }
          .to raise_error(TaxonWorks::Error::API, /start_date/)
      end

      specify 'raises on invalid end_date' do
        expect { q_api.set_date_params(start_date: '2020-06-01', end_date: '2020-13-01') }
          .to raise_error(TaxonWorks::Error::API, /end_date/)
      end
    end
  end

end
