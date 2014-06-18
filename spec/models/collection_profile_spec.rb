require 'spec_helper'

describe CollectionProfile do
  before(:all) do
    @collection_profile = FactoryGirl.build_stubbed(:collection_profile)
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(@collection_profile).to respond_to(:otu)
      end
      specify 'container' do
        expect(@collection_profile).to respond_to(:container)
      end
    end
  end

  context 'attributes' do 
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
  end

  context 'methods' do
    specify 'profile_indices' do
      expect(@collection_profile.collection_profile_indices.size).to eq(8)
    end
    specify 'average' do
      p = FactoryGirl.build_stubbed(:collection_profile, conservation_status: 2, processing_state: 2,
                                    container_condition: 2, condition_of_labels: 2, identification_level: 3,
                                    arrangement_level: 3, data_quality: 3, computerization_level: 3,
                                    number_of_collection_objects: nil)
      expect(p.average_profile_index).to eq(2.5)
    end
  end

  context 'validate' do
    specify 'valid profile' do
      p = FactoryGirl.create(:valid_collection_profile)
      expect(p.valid?).to be_true
    end
    specify 'missing fields' do
      p = FactoryGirl.build_stubbed(:collection_profile,
                                    conservation_status: 5,
                                    processing_state: 5,
                                    container_condition: 5,
                                    condition_of_labels: 5,
                                    identification_level: 5,
                                    arrangement_level: 5,
                                    data_quality: 5,
                                    computerization_level: 5,
                                    number_of_collection_objects: nil)
      expect(p.valid?).to be_false
      expect(p.errors.include?(:conservation_status)).to be_true
      expect(p.errors.include?(:processing_state)).to be_true
      expect(p.errors.include?(:container_condition)).to be_true
      expect(p.errors.include?(:condition_of_labels)).to be_true
      expect(p.errors.include?(:identification_level)).to be_true
      expect(p.errors.include?(:arrangement_level)).to be_true
      expect(p.errors.include?(:data_quality)).to be_true
      expect(p.errors.include?(:computerization_level)).to be_true
      expect(p.errors.include?(:number_of_collection_objects)).to be_true
      expect(p.errors.include?(:number_of_containers)).to be_true
    end
    specify 'invalid updated_at' do
      p = FactoryGirl.build_stubbed(:collection_profile)
      p.updated_at = Time.now + 5.days
      expect(p.valid?).to be_false
    end
  end

  context 'indices' do
    specify 'count' do
      expect(CollectionProfile.favret_conservation_status_indices('dry').size).to eq(3)
      expect(CollectionProfile.favret_conservation_status_indices('wet').size).to eq(3)
      expect(CollectionProfile.favret_conservation_status_indices('slide').size).to eq(3)
      expect(CollectionProfile.favret_processing_state_indices('dry').size).to eq(3)
      expect(CollectionProfile.favret_processing_state_indices('wet').size).to eq(3)
      expect(CollectionProfile.favret_processing_state_indices('slide').size).to eq(2)
      expect(CollectionProfile.favret_container_condition_indices('dry').size).to eq(4)
      expect(CollectionProfile.favret_container_condition_indices('wet').size).to eq(4)
      expect(CollectionProfile.favret_container_condition_indices('slide').size).to eq(4)
      expect(CollectionProfile.favret_condition_of_labels_indices('dry').size).to eq(3)
      expect(CollectionProfile.favret_condition_of_labels_indices('wet').size).to eq(3)
      expect(CollectionProfile.favret_condition_of_labels_indices('slide').size).to eq(3)
      expect(CollectionProfile.favret_identification_level_indices('dry').size).to eq(4)
      expect(CollectionProfile.favret_identification_level_indices('wet').size).to eq(4)
      expect(CollectionProfile.favret_identification_level_indices('slide').size).to eq(4)
      expect(CollectionProfile.favret_arrangement_level_indices('dry').size).to eq(4)
      expect(CollectionProfile.favret_arrangement_level_indices('wet').size).to eq(4)
      expect(CollectionProfile.favret_arrangement_level_indices('slide').size).to eq(4)
      expect(CollectionProfile.favret_data_quality_indices('dry').size).to eq(4)
      expect(CollectionProfile.favret_data_quality_indices('wet').size).to eq(4)
      expect(CollectionProfile.favret_data_quality_indices('slide').size).to eq(4)
      expect(CollectionProfile.favret_computerization_level_indices('dry').size).to eq(3)
      expect(CollectionProfile.favret_computerization_level_indices('wet').size).to eq(3)
      expect(CollectionProfile.favret_computerization_level_indices('slide').size).to eq(3)
      expect(CollectionProfile.favret_computerization_level_indices('aaa').size).to eq(0)
    end
    specify 'index value' do
      expect(CollectionProfile.favret_conservation_status_indices('dry')[1].class).to eq(String)
      expect(CollectionProfile.favret_conservation_status_indices('wet')[5]).to eq(nil)
    end
  end
end
