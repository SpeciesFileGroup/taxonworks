require 'rails_helper'

describe 'Shared::IsData', type: :model do

  let(:is_data_instance) { TestIsData.new }
  let(:is_data2_instance) { TestIsData2.new }
  let(:is_data_class) { TestIsData }
  let(:is_data_class2) { TestIsData2 }

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
      expect(is_data_subclass_instance.metamorphosize.class.name).to eq('TestIsData')
    end

    context 'comparing records' do
      context 'with IGNORE_CONSTANTS' do
        specify '#similar' do
          expect(is_data_instance.similar.to_a).to eq(TestIsData.none.to_a)
        end

        specify 'identical' do
          expect(is_data_instance.identical.to_a).to eq(TestIsData.none.to_a)
        end
      end

      context 'without IGNORE_CONSTANTS' do
        specify '#similar' do
          expect(is_data2_instance.similar.to_a).to eq(TestIsData2.none.to_a)
        end

        specify 'identical' do
          expect(is_data2_instance.identical.to_a).to eq(TestIsData2.none.to_a)
        end
      end
    end
  end

  context 'class methods' do
    context 'finding records' do
      context 'responding' do
        let(:attr) { is_data_instance.attributes }
        let(:attr2) { is_data2_instance.attributes }
        context 'with IGNORE_CONSTANTS' do
          specify '#similar' do
            expect(TestIsData.similar(attr).to_a).to eq(TestIsData.none.to_a)
          end

 #        specify 'identical' do
 #          expect(TestIsData.identical(attr).to_a).to eq(TestIsData.none.to_a)
 #        end
        end

        context 'without IGNORE_CONSTANTS' do
          specify '#similar' do
            expect(TestIsData2.similar(attr2).to_a).to eq(TestIsData2.none.to_a)
          end

 #        specify 'identical' do
 #          expect(TestIsData2.identical(attr2).to_a).to eq(TestIsData2.none.to_a)
 #        end
        end
      end
    end
  end

  
end

class TestIsData < ApplicationRecord
  include FakeTable
  include Shared::IsData
  # with IGNORE_CONSTANTS
  IGNORE_SIMILAR   = [:type, :parent_id].freeze
  IGNORE_IDENTICAL = [:type, :parent_id].freeze
end

class TestIsData2 < ApplicationRecord
  include FakeTable
  include Shared::IsData
  # without IGNORE_CONSTANTS
end

class TestIsDataSubclass < TestIsData
end
