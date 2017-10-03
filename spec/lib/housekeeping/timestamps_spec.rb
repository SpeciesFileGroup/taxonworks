require 'rails_helper'

describe 'Housekeeping::Timestamps' do

  let!(:user) { FactoryGirl.create(:valid_user, id: 1, name: 'Ren') }

  context 'Timestamps' do

    let(:instance) {
      stub_model(HousekeepingTestClass::WithTimestamps, id: 10)
    }

    context 'associations' do
      specify 'created_at' do
        expect(instance).to respond_to(:created_at)
      end

      specify 'updated_at' do
        expect(instance).to respond_to(:updated_at)
      end
    end

    context 'class scopes' do
      let!(:sp1) { FactoryGirl.create(:valid_geographic_item,
                                      creator:    user,
                                      updater:    user,
                                      created_at: '2017-1-1',
                                      updated_at: '2017-2-2') }
      let!(:sp2) { FactoryGirl.create(:valid_geographic_item,
                                      creator:    user,
                                      updater:    user,
                                      created_at: '2017-10-3',
                                      updated_at: '2017-10-3') }

      specify 'created_in_date_range' do
        expect(GeographicItem.created_in_date_range('12-31-16', '12/31/17').count).to eq(2)
        expect(GeographicItem.created_in_date_range('12-31-16', '2/28/17').count).to eq(1)
        expect(GeographicItem.created_in_date_range('1-31-17', Time.now).count).to eq(1)
        expect(GeographicItem.created_in_date_range('2001-1-1', '2001-12-31').count).to eq(0)
        expect(GeographicItem.created_in_date_range('2017-10-3', '2017-10-3').count).to eq(1)
      end

      specify 'updated_by_user' do
        expect(GeographicItem.updated_in_date_range('12-31-16', '12/31/17').count).to eq(2)
        expect(GeographicItem.updated_in_date_range('12-31-16', '2/28/17').count).to eq(1)
        expect(GeographicItem.updated_in_date_range('1-31-17', '2017-10-2').count).to eq(1)
        expect(GeographicItem.updated_in_date_range('2001-1-1', '2001-12-31').count).to eq(0)
        expect(GeographicItem.updated_in_date_range('2017-10-3', '2017-10-3').count).to eq(1)
      end

      specify 'created_before_date' do
        expect(GeographicItem.created_before_date('2/1/16').count).to eq(0)
        expect(GeographicItem.created_before_date('2/1/17').count).to eq(1)
        expect(GeographicItem.created_before_date('2/1/18').count).to eq(2)
      end
    end
  end
end

module HousekeepingTestClass
  class WithBoth < ApplicationRecord
    include FakeTable
    include Housekeeping
  end

  class WithTimestamps < ApplicationRecord
    include FakeTable
    include Housekeeping::Timestamps
  end

end
