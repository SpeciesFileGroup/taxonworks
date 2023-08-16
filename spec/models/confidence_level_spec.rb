require 'rails_helper'

describe ConfidenceLevel, type: :model, group: :confidences do

  let(:confidence_level) { ConfidenceLevel.new }
  let(:otu) { FactoryBot.create(:valid_otu) }

  let(:k1) { FactoryBot.create(:valid_confidence_level) }
  let(:k2) { FactoryBot.create(:valid_confidence_level) }

  specify '#confidences' do
    expect(confidence_level.confidences << Confidence.new(confidence_object: otu) ).to be_truthy
  end

  context 'validation' do
    specify 'can be used for confidences' do
      t = Confidence.new(confidence_level: k1, confidence_object: FactoryBot.build(:valid_otu))
      expect(t.save).to be_truthy
    end

    specify 'can not be used for other things' do
      expect {c = CitationTopic.new(topic: k1)}.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end
  end

  context 'scopes' do
    let!(:confidence) { Confidence.create!(confidence_level: k1, confidence_object: otu) }
    let!(:old_confidence) { Confidence.create!(confidence_level: k2, confidence_object: otu, created_at: 4.years.ago, updated_at: 4.years.ago) }
    let!(:new_confidence) { Confidence.create!(confidence_level: k1, confidence_object: FactoryBot.create(:valid_specimen)) }

    specify '#used_on_klass 1' do
      expect(ConfidenceLevel.used_on_klass('Otu')).to contain_exactly(k1, k2)
    end

    specify '#used_on_klass 2' do
      expect(ConfidenceLevel.used_on_klass('CollectionObject')).to contain_exactly(k1)
    end

    specify '#used_recently' do
      expect(ConfidenceLevel.used_recently(k1.created_by_id, k1.project_id, 'CollectionObject')).to contain_exactly(k1.id)
    end

    specify '#used_on_klass.used_recently' do
      expect(ConfidenceLevel.used_recently(k1.created_by_id, k1.project_id, 'Otu')).to contain_exactly(k1.id)
    end
  end

  context 'confidence objects' do

    context 'confidences' do

      let!(:t1) { Confidence.create(confidence_level: k1, confidence_object: FactoryBot.create(:valid_otu)) }
      let!(:t2) { Confidence.create(confidence_level: k1, confidence_object: FactoryBot.create(:valid_specimen)) }

      specify '#confidenced_objects' do
        expect(confidence_level).to respond_to(:confidenced_objects)
      end

      specify '#confidences' do
        expect(k1.confidences).to contain_exactly(t1, t2)
      end

      specify '#confidenced_objects' do
        expect(k1.confidenced_objects.count).to eq(2)
      end

      specify '#confidenced_object_class_names' do
        expect(k1.confidenced_object_class_names).to eq(%w{Otu CollectionObject})
      end
    end

  end
end

