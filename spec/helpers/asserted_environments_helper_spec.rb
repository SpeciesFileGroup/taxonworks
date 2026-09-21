require 'rails_helper'

describe AssertedEnvironmentsHelper, type: :helper do

  let(:asserted_environment) {
    FactoryBot.create(:valid_asserted_environment,
      uri: 'http://purl.obolibrary.org/obo/ENVO_00002007',
      uri_label: 'temperate forest biome')
  }

  specify '#label_for_asserted_environment' do
    expect(helper.label_for_asserted_environment(asserted_environment)).to eq('temperate forest biome')
  end

  specify '#label_for_asserted_environment with nil' do
    expect(helper.label_for_asserted_environment(nil)).to be_nil
  end

  specify '#asserted_environment_tag' do
    expect(helper.asserted_environment_tag(asserted_environment)).to include('temperate forest biome')
  end

  specify '#asserted_environment_autoselect_info' do
    expect(helper.asserted_environment_autoselect_info(asserted_environment)).to eq(['ENVO_00002007'])
  end

end
