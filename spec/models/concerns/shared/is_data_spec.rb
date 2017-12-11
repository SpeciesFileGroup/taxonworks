require 'rails_helper'

describe 'Shared::IsData', type: :model do

  let(:is_data_instance) { TestIsData.new }
  let(:is_data_class) { TestIsData }

  let(:is_data_subclass_instance) { TestIsDataSubclass.new }

  context 'instance methods' do

    specify '#is_in_use?' do
      expect(is_data_instance.is_in_use?).to eq(false)
    end

    specify '#is_community?' do
      expect(is_data_instance.is_community?).to eq(false)
    end

    specify '#has_loans?' do
      expect(is_data_instance.has_loans?).to eq(false)
    end

    specify '#metamorphosize' do
      expect(is_data_subclass_instance.metamorphosize.class.name).to eq('TestIsData' )
    end
 
  end
end

class TestIsData < ApplicationRecord
  include FakeTable
  include Shared::IsData
end

class TestIsDataSubclass < TestIsData
end
