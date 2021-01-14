require 'rspec'
require 'rails_helper'

# These are meta-model tests
#
#
describe TaxonWorks, group: :lint do
  # Since Rails doesn't load classes unless it needs them, so you must eager load them to get all the models.
  Rails.application.eager_load!

  context 'model includes/attributes', lint: true do
    ApplicationRecord.descendants.each {|model|
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

      # if model <= Shared::Annotates
      #   it "#{model} should define an #annotated_object method" do
      #     expect(model.new).to respond_to(:annotated_object)
      #   end
      # end

      if model.column_names.include?('project_id') && !model.name == 'ProjectMember'
        it "#{model} should include Housekeeping::Projects" do
          expect(model <= Housekeeping::Projects).to be(true)
        end
      end
    }
  end

  context 'nilifying blanks' do
    let(:m) { TaxonWorksModels::GenericModel.new }

    specify 'strings are converted to nil' do
      m.string = ''
      m.save!
      expect(m.string).to eq(nil)
    end

    specify 'text is converted to nil' do
      m.text = ''
      m.save!
      expect(m.text).to eq(nil)
    end

    specify 'boolean is untouched when false' do
      m.boolean = false
      m.save!
      expect(m.boolean).to eq(false)
    end

    specify 'integer 0 is untouched' do
      m.integer = 0
      m.save!
      expect(m.integer).to eq(0)
    end
  end
end

module TaxonWorksModels
  class GenericModel < ApplicationRecord
    include FakeTable
  end
end

