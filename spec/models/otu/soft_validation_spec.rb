require 'rails_helper'

describe 'Otu - SoftValidation', type: :model, group: [:otu, :soft_validation] do

  let(:otu) { Otu.new }

  specify 'OTU is missing taxon_name_id' do
    otu.soft_validate(only_sets: :taxon_name)
    expect(otu.soft_validations.messages_on(:taxon_name_id).count).to eq(1)
  end

  specify 'duplicate OTU' do
    o1 = FactoryBot.create(:otu, name: 'Aus')
    o2 = FactoryBot.build_stubbed(:otu, name: 'Aus')
    
    o1.soft_validate(only_sets: :duplicate_otu)
    expect(o1.soft_validations.messages_on(:taxon_name_id).empty?).to be_truthy

    o2.soft_validate(only_sets: :duplicate_otu)
    expect(o2.soft_validations.messages_on(:taxon_name_id).count).to eq(1)
  end

end
