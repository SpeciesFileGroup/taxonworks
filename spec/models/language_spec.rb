require 'rails_helper'

describe Language do

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

  context 'find values' do
    before(:each) do
      @eng = FactoryGirl.build(:english)
      @eng.save
      @rus = FactoryGirl.build(:russian)
      @rus.save
      @cre = FactoryGirl.build(:creole_eng)
      @cre.save
    end

    specify 'eng_name scope should return a list of matching languages(like)' do
      lang_a = Language.eng_name_contains('russ')
      expect(lang_a.count).to eq(1)
      expect(lang_a[0].id).to eq(@rus.id)
      lang_a = Language.eng_name_contains('Englis')
      expect(lang_a.count).to eq(2)
      expect(lang_a[0].id).to eq(@eng.id)
      expect(lang_a[1].id).to eq(@cre.id)
    end

    specify 'exact_abr should return a single object or nil' do
      result = Language.exact_abr('cpe')
      expect(result.id).to eq(@cre.id)
      result = Language.exact_abr('not')
      expect(result).to be_nil
    end

    specify 'exact_eng_name should return a single object or nil' do
      result = Language.exact_eng('English')
      expect(result.id).to eq(@eng.id)
      result = Language.exact_eng('English,')
      expect(result).to be_nil
    end
  end

end
