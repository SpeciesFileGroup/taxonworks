require 'rspec'
require 'rails_helper'

describe TaxonWorks do
  #let(:model_data) {} # Models that inherit ActiveRecord::Base

  context 'Models that have alternate values' do
    ActiveRecord::Base.descendants.each { |model|
      if model < Shared::AlternateValues
        it 'should define the array ALTERNATE_VALUES_FOR' do
          expect(model::ALTERNATE_VALUES_FOR).to be_an(Array), "model #{model}"
        end

        it 'should have 1 or more values in ALTERNATE_VALUES_FOR' do
          expect(model::ALTERNATE_VALUES_FOR.count).to be > 0, "model #{model}"
        end

        it 'should have only strings in ALTERNATE_VALUES_FOR' do
          model::ALTERNATE_VALUES_FOR.each { |val|
            pending("#{val} should be a column in #{model}")
            fail()
            # expect(val).to be_a(???) , "model #{model}"
          }
        end
      end
    }
  end

end
