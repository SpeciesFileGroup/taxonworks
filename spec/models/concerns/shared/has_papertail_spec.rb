require 'rails_helper'

describe 'HasPapertrail', type: :model, versioning: true do
  let(:class_with_papertrail) {TestHasPapertrail.create!(string: 'ABC')}

  specify 'has many #versions' do
    expect(class_with_papertrail).to respond_to(:versions)
  end

  specify 'does not create a version on create' do
    expect(class_with_papertrail.versions.count == 0).to be_truthy 
  end

  specify 'does not create a version on destroy' do
    class_with_papertrail.destroy
    expect(PaperTrail::Version.all.count).to eq(0)
  end

  specify 'on update a version is created' do
    class_with_papertrail.update(string: 'DEF')
    class_with_papertrail.save!
    expect(class_with_papertrail.versions.count).to eq(1)
  end

  context 'attribute updater/updated_at' do
    let(:user_a) {FactoryBot.create(:valid_user)}
    let(:user_b) {FactoryBot.create(:valid_user)}
    let(:user_c) {FactoryBot.create(:valid_user)}
    let(:date_a) { DateTime.new(2025, 1, 1) }
    let(:date_b) { DateTime.new(2025, 1, 3) }
    let(:date_c) { DateTime.new(2025, 1, 10) }
    let!(:untouched) do 
      Current.user_id = user_c.id
      TestHasPapertrail.create!(string: 'ABC')
    end
    let!(:touched) do
      Timecop.travel(date_a) do
        Current.user_id = user_a.id
        TestHasPapertrail.create!(string: 'ABC')
      end
    end

    before do
      Timecop.travel(date_b) do
        Current.user_id = user_b.id
        touched.update!(string: 'DEF', text: 'ABC')
      end
      Timecop.travel(date_c) do
        Current.user_id = user_c.id
        touched.update!(string: 'GHI')
      end
    end

    describe '#attribute_updater' do
      it 'returns creator on untouched object' do
        expect(untouched.attribute_updater(:string)).to eq(user_c.id)        
      end

      it 'returns creator on untouched attributes' do
        expect(touched.attribute_updater(:boolean)).to eq(user_a.id)
      end

      it 'returns updater on touched attributes (example 1)' do
        expect(touched.attribute_updater(:text)).to eq(user_b.id)
      end

      it 'returns updater on touched attributes (example 2)' do
        expect(touched.attribute_updater(:string)).to eq(user_c.id)
      end
    end
    
    describe '#attribute_updated' do
      it 'returns creation time on untouched object' do
        expect(untouched.attribute_updated(:string)).to be_within(1.minute).of Time.now        
      end

      it 'returns creation time on untouched attributes' do
        expect(touched.attribute_updated(:boolean)).to be_within(1.minute).of date_a
      end

      it 'returns update time of touched attributes (example 1)' do
        expect(touched.attribute_updated(:text)).to be_within(1.minute).of date_b
      end

      it 'returns update time of touched attributes (example 2)' do
        expect(touched.attribute_updated(:string)).to be_within(1.minute).of date_c
      end
    end
  end
end

class TestHasPapertrail < ApplicationRecord
  include FakeTable
  include Shared::HasPapertrail
  include Housekeeping
end

