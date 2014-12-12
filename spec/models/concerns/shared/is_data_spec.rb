require 'rspec'

describe Shared::IsData do

  let(:is_data_instance) { TestIsData.new }
  let(:is_data_class) { TestIsData }

  context 'instance methods' do

    # Repeat for every has_plural_noun
    specify 'has_citations?' do
      expect(is_data_instance.has_citations?).to eq(false)
    end
  end



#  has_pluralnouns tests
end


class TestIsData < ActiveRecord::Base
  include FakeTable
  include Shared::IsData
end
