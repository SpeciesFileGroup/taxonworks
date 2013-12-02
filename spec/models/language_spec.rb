require 'spec_helper'

describe Language do

  let(:language) {Language.new}

  context 'validation' do
    before(:each) {
     language.valid?
    } 
    specify 'require english_name' do
      expect(language.errors.include?(:english_name)).to be_true
    end

    specify 'require alpha_3_bibliographic' do
      expect(language.errors.include?(:alpha_3_bibliographic)).to be_true
    end
  end
end
