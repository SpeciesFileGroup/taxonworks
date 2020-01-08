require 'rails_helper'

describe Language, type: :model do

  let(:language) {Language.new}

  context 'validation' do
    before(:each) {
      language.valid?
    }
    specify 'require english_name' do
      expect(language.errors.include?(:english_name)).to be_truthy
    end

    specify 'require alpha_3_bibliographic' do
      expect(language.errors.include?(:alpha_3_bibliographic)).to be_truthy
    end
  end

  specify '.select_optimized' do
    expect(Language.select_optimized(Current.user_id, Current.project_id)).to be_truthy
  end

  context 'find values' do
    let!(:eng) { FactoryBot.create(:english) }
    let!(:rus) { FactoryBot.create(:russian) }
    let!(:cre) { FactoryBot.create(:creole_eng) }

    specify '#with_english_name_containing scope should return a list of matching languages(like)' do
      lang_a = Language.with_english_name_containing('russ')
      expect(lang_a.count).to eq(1)
      expect(lang_a[0].id).to eq(rus.id)
      lang_a = Language.with_english_name_containing('Englis')
      expect(lang_a.count).to eq(2)
      expect(lang_a[0].id).to eq(eng.id)
      expect(lang_a[1].id).to eq(cre.id)
    end

    specify 'finding by abbreviation return a single object or nil' do
      result = Language.where(alpha_3_bibliographic: 'cpe').first
      expect(result.id).to eq(cre.id)
      result = Language.where(alpha_3_bibliographic: 'not').first
      expect(result).to be_nil
    end

    specify 'finding by exact english_name should return a single object or nil' do
      result = Language.where(english_name: 'English').first
      expect(result.id).to eq(eng.id)
      result = Language.where(english_name: 'English,').first
      expect(result).to be_nil
    end

    specify '#with_english_name_or_abbreviation finds exact in many fields for String search value' do
      expect(Language.with_english_name_or_abbreviation('eng').count).to eq(1)
    end

    specify '#with_english_name_or_abbreviation finds exact in many fields for Array search value' do
      expect(Language.with_english_name_or_abbreviation(['eng', 'Russian']).count).to eq(2)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
