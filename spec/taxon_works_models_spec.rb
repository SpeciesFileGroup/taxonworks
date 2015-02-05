require 'rspec'
require 'rails_helper'

describe TaxonWorks do
  #let(:model_data) {} # Models that inherit ActiveRecord::Base

  # Since Rails doesn't load classes unless it needs them, so you must eager load them to get all the models.
  Rails.application.eager_load!

  #todo need to fix it so that the error message appears along with the project name.
  context 'model includes/attributes' do
    ActiveRecord::Base.descendants.each { |model|

      if model < Shared::AlternateValues
        it "#{model} should define the array ALTERNATE_VALUES_FOR" do
          expect(model::ALTERNATE_VALUES_FOR).to be_an(Array), "#{model} is missing ALTERNATE_VALUES_FOR"
        end

        it "#{model} should have 1 or more values in ALTERNATE_VALUES_FOR" do
          expect(model::ALTERNATE_VALUES_FOR.count).to be > 0, "#{model} ALTERNATE_VALUES_FOR.count is 0"
        end

        it "#{model} should have only valid columns in ALTERNATE_VALUES_FOR" do
          model::ALTERNATE_VALUES_FOR.each { |val|
            expect(model.attribute_names.include?(val.to_s)).to be_truthy, "#{val} (from ALTERNATE_VALUES_FOR) is not a valid attribute of #{model}"
          }
        end
      end

      if model <= Shared::Annotates
        it "#{model} should define an #annotated_object method" do
          expect(model.new).to respond_to(:annotated_object) 
        end
      end
    }
  end

end
