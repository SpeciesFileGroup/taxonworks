require 'rails_helper'

describe 'Confidences', type: :model, group: :confidence do
  let(:class_with_confidences) { TestConfidence.new }
  let(:confidence_level) {FactoryBot.create(:valid_confidence_level)}

  context 'associations' do
    specify 'has many confidences' do
      expect(class_with_confidences).to respond_to(:confidences)
      expect(class_with_confidences.confidences.to_a).to eq([]) # there are no confidences yet.

      expect(class_with_confidences.confidences << FactoryBot.build(:valid_confidence)).to be_truthy
      expect(class_with_confidences.confidences.size).to eq(1)
      expect(class_with_confidences.save).to be_truthy
      class_with_confidences.reload

      expect(class_with_confidences.confidences.count).to eq(1)
    end
  end

  context 'scopes' do
    context '.with_confidences' do
      before {
        FactoryBot.create(:valid_confidence_level)
        Confidence.create(confidence_object: class_with_confidences, confidence_level: confidence_level)
      }

      specify 'without confidences' do
        expect(class_with_confidences.class.without_confidences.count).to eq(0)
      end

      specify 'with_confidences' do
        expect(class_with_confidences.class.with_confidences.pluck(:id)).to eq( [ class_with_confidences.id  ] )
      end
    end

    context '.without_confidences' do
      specify 'without confidences' do
        class_with_confidences.save
        expect(TestConfidence.without_confidences.pluck(:id)).to eq([class_with_confidences.id])
      end

      specify 'with_confidences' do
        expect(class_with_confidences.class.with_confidences.to_a).to eq( [ ] )
      end
    end
  end

  context 'methods' do
    context 'object with Confidences on destroy' do
      specify 'attached Confidences are destroyed' do
        expect(Confidence.count).to eq(0)
        class_with_confidences.confidences << Confidence.new(confidence_level: FactoryBot.create(:valid_confidence_level))
        class_with_confidences.save
        expect(Confidence.count).to eq(1)
        expect(class_with_confidences.destroy).to be_truthy
        expect(Confidence.count).to eq(0)
      end
    end
  end
end

class TestConfidence < ApplicationRecord
  include FakeTable
  include Shared::Confidences
end


