require 'rails_helper'

describe 'Labels', type: :model do

  let(:labels_instance) {TestLabels.new}
  let(:labels_class) {TestLabels}

  context 'associations' do
    specify 'has many labels' do
      expect(labels_instance.labels << Label.new).to be_truthy
    end
  end

   context 'methods' do
    specify '.labeled?' do
      expect(labels_instance.labeled?).to eq(false)
    end

    specify 'labeled? with some labels' do
      labels_instance.labels << Label.new(text: 'this is a label')
      expect(labels_instance.labeled?).to eq(true)
    end

    context 'with some records created' do

      let!(:label1) { FactoryBot.create(:valid_label, label_object: labels_instance, text: 'first label') }
      let!(:label2) { FactoryBot.create(:valid_label, label_object: labels_instance, text: 'second label',) }
      let!(:label3) { FactoryBot.create(:valid_label, label_object: labels_instance, text: 'third label') }

      specify '#labeled?' do
        expect(labels_instance.labeled?).to eq(true)
      end

      specify '#unprinted' do
        expect(labels_instance.labels.unprinted).to contain_exactly(label1, label2, label3)
      end


      context 'on destroy' do
        specify 'attached labels are destroyed' do
          expect(labels_instance.labels.count).to eq(3)
          expect(labels_instance.destroy).to be_truthy
          expect(Label.count).to eq(0)
        end
      end
    end
  end
end

class TestLabels < ApplicationRecord
  include FakeTable
  include Shared::Labels
end


