require 'rails_helper'

RSpec.describe CommonName, type: :model do

  let(:common_name) { CommonName.new }
  let(:otu) { FactoryBot.create(:valid_otu) }

  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(common_name.otu = Otu.new).to be_truthy
      end

      specify 'language' do
        expect(common_name.language = Language.new).to be_truthy
      end

      specify 'geographic_area' do
        expect(common_name.geographic_area = GeographicArea.new).to be_truthy
      end
    end
  end

  context 'validation' do
    specify 'common_name without name is invalid' do
      expect(common_name.valid?).to be_falsey
    end

    specify 'common_name only requires name and otu' do
      common_name.name = 'the blob'
      common_name.otu = otu
      expect(common_name.valid?).to be_truthy
    end

    context 'year validation' do
      before {common_name.name = 'slimy'; common_name.otu = otu}
      specify 'non 4 digit start_year is invalid if provided' do
        common_name.start_year = 23
        expect(common_name.valid?).to be_falsey
      end

      specify 'non 4 digit end_year is invalid if provided' do
        common_name.end_year = 23
        expect(common_name.valid?).to be_falsey
      end

      specify '4 digit end_year is valid if provided' do
        common_name.end_year = 2012
        expect(common_name.valid?).to be_truthy
      end

      specify '4 digit start_year is valid if provided' do
        common_name.end_year = 1958 
        expect(common_name.valid?).to be_truthy
      end
  
      specify 'can not start (too far) into the future' do
        common_name.start_year = Time.now.year + 6
        expect(common_name.valid?).to be_falsey
      end

      specify 'can not start (too far) into the past' do
        common_name.start_year = -4000 
        expect(common_name.valid?).to be_falsey
      end
    end
  end
end
