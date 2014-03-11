require 'spec_helper'

describe CollectionProfile do
  before(:all) do
    @collection_profile = FactoryGirl.build_stubbed(:collection_profile)
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'conservation_status' do
        expect(@collection_profile).to respond_to(:conservation_status)
      end
      specify 'processing_state' do
        expect(@collection_profile).to respond_to(:processing_state)
      end
      specify 'container_condition' do
        expect(@collection_profile).to respond_to(:container_condition)
      end
      specify 'condition_of_labels' do
        expect(@collection_profile).to respond_to(:condition_of_labels)
      end
      specify 'identification_level' do
        expect(@collection_profile).to respond_to(:identification_level)
      end
      specify 'arrangement_level' do
        expect(@collection_profile).to respond_to(:arrangement_level)
      end
      specify 'data_quality' do
        expect(@collection_profile).to respond_to(:data_quality)
      end
      specify 'computerization_level' do
        expect(@collection_profile).to respond_to(:computerization_level)
      end

      specify 'otu' do
        expect(@collection_profile).to respond_to(:otu)
      end
      specify 'container' do
        expect(@collection_profile).to respond_to(:container)
      end
    end
  end

  context 'indices' do
    specify 'count' do
      expect(CollectionProfile.favret_conservation_status_indices('dry').count).to eq(3)
      expect(CollectionProfile.favret_conservation_status_indices('wet').count).to eq(3)
      expect(CollectionProfile.favret_conservation_status_indices('slide').count).to eq(3)
      expect(CollectionProfile.favret_processing_state_indices('dry').count).to eq(3)
      expect(CollectionProfile.favret_processing_state_indices('wet').count).to eq(3)
      expect(CollectionProfile.favret_processing_state_indices('slide').count).to eq(2)
      expect(CollectionProfile.favret_container_condition_indices('dry').count).to eq(4)
      expect(CollectionProfile.favret_container_condition_indices('wet').count).to eq(4)
      expect(CollectionProfile.favret_container_condition_indices('slide').count).to eq(4)
      expect(CollectionProfile.favret_condition_of_labels_indices('dry').count).to eq(3)
      expect(CollectionProfile.favret_condition_of_labels_indices('wet').count).to eq(3)
      expect(CollectionProfile.favret_condition_of_labels_indices('slide').count).to eq(3)
      expect(CollectionProfile.favret_identification_level_indices('dry').count).to eq(4)
      expect(CollectionProfile.favret_identification_level_indices('wet').count).to eq(4)
      expect(CollectionProfile.favret_identification_level_indices('slide').count).to eq(4)
      expect(CollectionProfile.favret_arrangement_level_indices('dry').count).to eq(4)
      expect(CollectionProfile.favret_arrangement_level_indices('wet').count).to eq(4)
      expect(CollectionProfile.favret_arrangement_level_indices('slide').count).to eq(4)
      expect(CollectionProfile.favret_data_quality_indices('dry').count).to eq(4)
      expect(CollectionProfile.favret_data_quality_indices('wet').count).to eq(4)
      expect(CollectionProfile.favret_data_quality_indices('slide').count).to eq(4)
      expect(CollectionProfile.favret_computerization_level_indices('dry').count).to eq(3)
      expect(CollectionProfile.favret_computerization_level_indices('wet').count).to eq(3)
      expect(CollectionProfile.favret_computerization_level_indices('slide').count).to eq(3)
      expect(CollectionProfile.favret_computerization_level_indices('aaa').count).to eq(0)
    end
  end
end
