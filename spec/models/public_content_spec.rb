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

  # See the Papertrail gem https://github.com/airblade/paper_trail
  context 'use', :versioning => true do
    specify 'within a `with_versioning` block it will be turned on' do
      PaperTrail.should be_enabled
    end

    context 'some Paptertrail methods' do
      before(:each) {
        @c = FactoryGirl.build(:valid_public_content)
        @c.save!
      }

      specify 'versions' do
        expect(@c.versions).to have(1).things 
      end

      specify 'another version' do
        @c.text = 'new text'
        expect(@c.save).to be_true
        expect(@c.versions).to have(2).things
      end

      specify 'live?'  do
        expect(@c.live?).to be_true
      end
    end
  end
end
