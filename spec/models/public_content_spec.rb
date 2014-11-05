require 'rails_helper'

describe PublicContent, :type => :model do
  let(:public_content) {FactoryGirl.build(:public_content) }

  context 'validation' do
    before(:each) {
      public_content.valid?
    }

    context 'requires' do
      specify 'topic' do
        expect(public_content.errors.include?(:topic)).to be_truthy
      end
      specify 'text' do
        expect(public_content.errors.include?(:text)).to be_truthy
      end
    end
  end

end
