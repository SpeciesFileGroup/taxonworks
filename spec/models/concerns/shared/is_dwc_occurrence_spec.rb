require 'rails_helper'

describe 'IsDwcOccurrence', type: :model, group: :darwin_core do

  let(:class_with_dwc_occurrence) {TestIsDwcOccurrence.new}
  let(:collection_object) { FactoryBot.create(:valid_specimen) }
  let(:dwc_occurrence) {class_with_dwc_occurrence.dwc_occurrence}

  specify 'has one #dwc_occurrence' do
    expect(class_with_dwc_occurrence).to respond_to(:dwc_occurrence)
  end

  context 'generating a dwc_occurrence' do
    context 'by default' do
      before { class_with_dwc_occurrence.save! }

      specify 'a dwc_occurrence record is created' do
        expect(class_with_dwc_occurrence.dwc_occurrence_persisted?).to be_truthy
      end

      specify '#set_dwc_occurrence returns' do
        expect(class_with_dwc_occurrence.set_dwc_occurrence).to be_kind_of(DwcOccurrence)
      end

      specify '#stale?' do
        expect(class_with_dwc_occurrence.dwc_occurrence.stale?).to be_falsey
      end

      specify 'updating #dwc_occurrence uses the existing record' do
        old_id = class_with_dwc_occurrence.dwc_occurrence.id
        class_with_dwc_occurrence.set_dwc_occurrence
        expect( class_with_dwc_occurrence.dwc_occurrence.id).to eq(old_id)
      end

      specify 'updating an existing #dwc_occurrence touches updated_at' do
        a = class_with_dwc_occurrence.dwc_occurrence.updated_at
        class_with_dwc_occurrence.set_dwc_occurrence

        # More recent times are less than more distant times, the `<=>` opperator returns -1, 0, 1 respectively
        expect( class_with_dwc_occurrence.updated_at <=> a).to eq(-1)
      end
    end

    specify '#no_dwc_occurrence = true prevents creation' do
      class_with_dwc_occurrence.no_dwc_occurrence = true
      class_with_dwc_occurrence.save!
      expect(class_with_dwc_occurrence.dwc_occurrence_persisted?).to be_falsey
    end

    specify 'a map between TW and DWC attributes is defined in DWC_OCCURRENCE_METADATA' do
      expect(TestIsDwcOccurrence::DWC_OCCURRENCE_MAP).to be_truthy
    end

    context 'DWC_OCCURRENCE_METADATA map is used to' do
      before {class_with_dwc_occurrence.save!}
      specify 'generate #dwc_occurrence_attributes' do
        expect(class_with_dwc_occurrence.dwc_occurrence_attributes).to include(island: 'Gold', disposition: 'Old Men')
      end

      specify 'set attributes named in #keys by the methods in #values' do
        expect(dwc_occurrence.island).to eq('Gold')
        expect(dwc_occurrence.disposition).to eq('Old Men')
      end
    end
  end
end


class TestIsDwcOccurrence < ApplicationRecord
  include FakeTable
  include Shared::IsDwcOccurrence

  include Shared::Identifiers
  include Shared::IsData

  include Housekeeping

  DWC_OCCURRENCE_MAP = {
    island: :treasure,
    disposition: :grumpy
  }.freeze

  def treasure
    'Gold'
  end

  def grumpy
    'Old Men'
  end

end


