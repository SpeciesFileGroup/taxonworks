require 'rails_helper'

describe 'AlternateValue::Translation', :type => :model do

  let (:translation) { AlternateValue::Translation.new }

  context 'validation' do
    context 'required' do
      before(:each) {
        translation.valid?
      }
      specify 'language' do
        expect(translation.errors.include?(:language)).to be_truthy
      end
    end
  end
end
