require 'rails_helper'

describe CollectionProfile, type: :model do
  let(:collection_profile) { FactoryBot.build(:collection_profile) }

  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(collection_profile).to respond_to(:otu)
      end
      specify 'container' do
        expect(collection_profile).to respond_to(:container)
      end
    end
  end

  context 'attributes include' do
    COLLECTION_PROFILE_INDICES[:Favret][:wet].keys.each do |k|
      specify "#{k}" do
        expect(collection_profile).to respond_to(k)
      end
    end
  end

  context 'validation' do
    let(:dry_collection_profile) { FactoryBot.create(:dry_collection_profile) }

    specify 'a valid profile' do
      expect(dry_collection_profile.valid?).to be_truthy
    end

    context 'data is restricted to legal values' do
      let(:p) { FactoryBot.build_stubbed(:dry_collection_profile,
                                          conservation_status: 5,
                                          processing_state: 5,
                                          container_condition: 5,
                                          condition_of_labels: 5,
                                          identification_level: 5,
                                          arrangement_level: 5,
                                          data_quality: 5,
                                          computerization_level: 5) 
      }

      specify 'for all profile attributes' do
        expect(p.valid?).to be_falsey
      end

      context 'Favret - nothing matches 5' do
        before { p.valid? }
        
        COLLECTION_PROFILE_INDICES[:Favret][:dry].keys.each do |k|
          specify "#{k}" do
            expect(p.errors.include?(k.to_sym)).to be_truthy 
          end
        end
      end
    end

    context 'updates' do
      let!(:p) { FactoryBot.create(:dry_collection_profile) }
      before {   p.updated_at = Time.now + 5.days }

      specify 'are not subsequently allowed' do
        expect(p.valid?).to be_falsey
      end

      specify 'unless forced' do
        p.force_update = true
        expect(p.valid?).to be_truthy
      end
    end 
  end # end validate

  context 'methods' do
    let(:indices) { 
      {  conservation_status: 2, processing_state: 2,
         container_condition: 2, condition_of_labels: 2, identification_level: 3,
         arrangement_level: 3, data_quality: 3, computerization_level: 3,
         number_of_collection_objects: nil }
    } 

    specify '#profile_indices when not all set' do
      expect(collection_profile.collection_profile_indices.size).to eq(0)
    end

    context 'with indices set' do
      before { collection_profile.update_attributes(indices) } 
      specify '#profile_indices when all set' do
        expect(collection_profile.collection_profile_indices.size).to eq(8)
      end

      specify '#average_profile_of_index' do
        expect(collection_profile.average_profile_index).to eq(2.5)
      end
    end
  end



  context 'indices' do
    specify 'size(?)' do
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:conservation_status].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:conservation_status].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:conservation_status].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:processing_state].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:processing_state].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:processing_state].size).to eq(2)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:container_condition].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:container_condition].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:container_condition].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:condition_of_labels].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:condition_of_labels].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:condition_of_labels].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:identification_level].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:identification_level].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:identification_level].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:arrangement_level].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:arrangement_level].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:arrangement_level].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:data_quality].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:data_quality].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:data_quality].size).to eq(4)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:computerization_level].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:wet][:computerization_level].size).to eq(3)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:slide][:computerization_level].size).to eq(3)
    end

    specify 'index value' do
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:conservation_status][1].class).to eq(String)
      expect(COLLECTION_PROFILE_INDICES[:Favret][:dry][:conservation_status][5]).to eq(nil)
    end

  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
