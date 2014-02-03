require 'spec_helper'

describe Content do

  let(:content) {FactoryGirl.build(:content) }

  context 'validation' do
    before(:each) {
      content.valid?
    }

    context 'requires' do
      specify 'otu' do
        expect(content.errors.include?(:otu)).to be_true
      end
      specify 'topic' do
        expect(content.errors.include?(:topic)).to be_true
      end
      specify 'text' do
        expect(content.errors.include?(:text)).to be_true
      end
    end

    context 'topic_id is of class Topic only' do
      pending
    end
  end
end
