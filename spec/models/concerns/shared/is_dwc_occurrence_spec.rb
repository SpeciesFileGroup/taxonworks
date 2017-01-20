require 'rails_helper'

describe 'IsDwcOccurrence', type: :model, group: :darwin_core do
  let(:class_with_dwc_occurrence) { TestIsDwcOccurrence.new } 
  let(:collection_object) { FactoryGirl.create(:valid_specimen) }
  let(:dwc_occurrence) {  class_with_dwc_occurrence.dwc_occurrence } 

  context 'associations' do
    specify 'has one dwc_occurrence' do
      expect(class_with_dwc_occurrence).to respond_to(:dwc_occurrence) 
    end
  end

  context 'generating a dwc_occurrence' do

    context 'by default' do
      before { class_with_dwc_occurrence.save }
      specify 'no dwc_occurrence record is created' do
        expect(class_with_dwc_occurrence.dwc_occurrence_persisted?).to be_falsey
      end
 
      context 'post creation serialization' do
        specify '#set_dwc_occurrence returns' do
          expect(class_with_dwc_occurrence.set_dwc_occurrence).to be_kind_of(DwcOccurrence) 
        end

        context 'updating dwc_occurence' do
         before { class_with_dwc_occurrence.set_dwc_occurrence }

         # TODO: if/when we check for identity need to change the record to force an update
         specify 'uses the existing record' do
           old_id = class_with_dwc_occurrence.dwc_occurrence.id 
           class_with_dwc_occurrence.set_dwc_occurrence
           expect( class_with_dwc_occurrence.dwc_occurrence.id).to eq(old_id)
         end
        end
      end

    end

    context '#generate_dwc_occurrence true' do
      before do
        class_with_dwc_occurrence.generate_dwc_occurrence = true
        class_with_dwc_occurrence.save
      end

      specify 'dwc_occurrence record is created' do
        expect(class_with_dwc_occurrence.dwc_occurrence_persisted?).to be_truthy 
      end

      specify 'dwc_occurrence is !#stale?' do
        expect(class_with_dwc_occurrence.dwc_occurrence.stale?).to be_falsey
      end

      context 'a map between TW and DWC attributes' do
        context 'is defined in' do
          specify 'in DWC_OCCURRENCE_METADATA' do
            expect(TestIsDwcOccurrence::DWC_OCCURRENCE_MAP).to be_truthy
          end
        end

        context 'is used to' do
          specify 'generate #dwc_occurrence_attributes' do
            expect(class_with_dwc_occurrence.dwc_occurrence_attributes).to eq({island: 'Gold', disposition: 'Old Men', project_id: nil, updated_by_id: nil, created_by_id: nil })
          end

          specify 'set attributes named in #keys by the methods in #values' do
            expect(dwc_occurrence.island).to eq('Gold')
            expect(dwc_occurrence.disposition).to eq('Old Men')
          end
        end
      end
    end

  
  end
end


class TestIsDwcOccurrence < ActiveRecord::Base
  include FakeTable
  include Shared::IsDwcOccurrence

  DWC_OCCURRENCE_MAP = {
    island: :treasure,
    disposition: :grumpy
  } 

  def treasure
    'Gold'
  end

  def grumpy
    'Old Men'
  end

end


