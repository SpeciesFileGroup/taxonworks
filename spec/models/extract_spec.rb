require 'rails_helper'

RSpec.describe Extract, type: :model, group: :extract do

  let(:extract) {Extract.new}

  context 'validations' do

    specify '.valid_new_object_classes' do
      expect(Extract.valid_new_object_classes).to contain_exactly('Extract', 'Sequence')
    end
    
    context 'fails when not given' do
      let(:empty_extract) { Extract.new }

      before(:each) { empty_extract.valid? }

      specify 'quantity_value' do
        expect(empty_extract.errors.include?(:quantity_value)).to be_truthy
      end

      specify 'quantity_unit' do
        expect(empty_extract.errors.include?(:quantity_unit)).to be_truthy
      end

      specify 'year_made' do
        expect(empty_extract.errors.include?(:year_made)).to be_truthy
      end

      specify 'month_made' do
        expect(empty_extract.errors.include?(:month_made)).to be_truthy
      end

      specify 'day_made' do
        expect(empty_extract.errors.include?(:day_made)).to be_truthy
      end
    end

    context '#quantity_unit format' do
      let(:a) { 
        a = Extract.new(quantity_value: '22')
      }

      specify 'adds errors when unknown by RubyUnits' do
        a.quantity_unit = 'foo'
        a.valid?
        expect(a.errors.include?(:quantity_unit)).to be_truthy
      end

      specify 'recognizes units' do
        a.quantity_unit = 'mm'
        a.valid?
        expect(a.errors.include?(:quantity_unit)).to be_falsey
      end
    end

    context 'sets dates with #is_made_now' do
      before {
        extract.is_made_now = true
        extract.quantity_value = 22
        extract.quantity_unit = 'mm'
        extract.save!
      }

      specify '#year_made is set' do
        expect(extract.year_made).to eq(Time.now.year)
      end

      specify '#month_made is set' do
        expect(extract.year_made).to eq(Time.now.year)
      end

      specify '#day_made is set' do
        expect(extract.year_made).to eq(Time.now.year)
      end
    end

    context 'fails when given invalid dates' do
      let(:valid_extract) {
        FactoryBot.build(:valid_extract)
      }

      after(:each){
        expect(valid_extract.valid?).to be_falsey
      }

      context 'year_made' do
        specify '< 1000' do 
          valid_extract.year_made = 999
        end

        specify '> Time.now.year + 5' do 
          valid_extract.year_made = Time.now.year + 6
        end
      end

      context 'month_made' do
        specify '< 1' do
          valid_extract.month_made = 0
        end

        specify '> 12' do
          valid_extract.month_made = 13
        end
      end

      context 'day_made' do
        specify '< 1' do
          valid_extract.day_made = 0
        end

        specify '> 31' do
          valid_extract.day_made = 32
        end
      end
    end

    context 'passes when given' do
      specify 'quantity_value and quantity_unit and concentration_value and concentration_unit and verbatim_anatomical_origin and year_made and month_made and day_made' do
        expect(FactoryBot.build(:valid_extract).valid?).to be_truthy
      end
    end

    # Method comes from concerns/shared/origin_relationship.rb
    context '#derived_sequences' do
      let(:e) { FactoryBot.create(:valid_extract) }
      before { 
        e.derived_sequences.create!(sequence: 'ACGT', sequence_type: 'DNA') }
        
      specify 'are returned' do
        expect(e.derived_sequences.count).to eq(1)
        expect(e.derived_sequences.first.sequence).to eq('ACGT')
      end
    end
  end
end
