require 'rails_helper'

describe 'Shared::IsData', type: :model do

  let(:is_data_instance) { TestIsData.new }
  let(:is_data_class) { TestIsData }

  context 'instance methods' do

    specify 'has_alternate_values?' do
      expect(is_data_instance.has_alternate_values?).to eq(false)
    end

    specify 'has_citations?' do
      expect(is_data_instance.has_citations?).to eq(false)
    end

    specify 'has_identifiers?' do
      expect(is_data_instance.has_identifiers?).to eq(false)
    end

    specify 'has_notes?' do
      expect(is_data_instance.has_notes?).to eq(false)
    end

    specify 'has_tags?' do
      expect(is_data_instance.has_tags?).to eq(false)
    end

    specify 'is_in_use?' do
      expect(is_data_instance.is_in_use?).to eq(false)
    end
  end

end

class TestIsData < ActiveRecord::Base
  include FakeTable
  include Shared::IsData 
end
