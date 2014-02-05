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

  context 'associations' do
    context 'has_one' do
      specify 'public_content' do
        expect(content).to respond_to(:public_content)
      end
    end
  end

  context 'publishing' do
    before(:each) {
      @content = FactoryGirl.create(:valid_content)
    }

    specify 'when you #publish there is PublicContent' do
      expect(@content.publish).to be_true
      expect(PublicContent.all).to have(1).things
    end

    specify 'a new version is not published for identically versioned content' do
      expect(@content.publish).to be_true
      expect(PublicContent.all).to have(1).things
      existing_public_version = @content.public_content.version
      expect(@content.version == existing_public_version ).to be_true
      expect(@content.publish).to be_true
      expect(PublicContent.all).to have(1).things
      expect(@content.public_content.version == existing_public_version).to be_true
    end

    specify 'when you #unpublish there is no PublicContent' do
      expect(@content.publish).to be_true
      expect(PublicContent.all).to have(1).things
      expect(@content.unpublish).to be_true
      expect(PublicContent.all).to have(0).things
    end
  end


  # See the Papertrail gem https://github.com/airblade/paper_trail
  context 'use', :versioning => true do
    specify 'within a `with_versioning` block it will be turned on' do
      PaperTrail.should be_enabled
    end

    context 'some Paptertrail methods' do
      before(:each) {
        @c = FactoryGirl.build(:valid_content)
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
