require 'spec_helper'

describe PublicContent do
  let(:public_content) {FactoryGirl.build(:public_content) }

  context 'validation' do
    before(:each) {
      public_content.valid?
    }

    context 'requires' do
      specify 'otu' do
        expect(public_content.errors.include?(:otu)).to be_true
      end
      specify 'topic' do
        expect(public_content.errors.include?(:topic)).to be_true
      end
      specify 'text' do
        expect(public_content.errors.include?(:text)).to be_true
      end
    end
  end

end
