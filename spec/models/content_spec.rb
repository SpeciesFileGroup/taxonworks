require 'spec_helper'

describe Content do

  let(:content) {FactoryGirl.build(:content) }

  context 'validation' do
    before(:each) {
      content.valid?
    }

    context 'requires' do
      specify 'otu' do
        expect(content.errors.include?(:otu)).to be_truthy
      end
      specify 'topic' do
        expect(content.errors.include?(:topic)).to be_truthy
      end
      specify 'text' do
        expect(content.errors.include?(:text)).to be_truthy
      end
    end

    context 'topic_id is of class Topic only' do
      skip 
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
      expect(@content.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
    end

    specify 'a new version is not published for identically versioned content' do
      expect(@content.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
      existing_public_version = @content.public_content.version
      expect(@content.version == existing_public_version ).to be_truthy
      expect(@content.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
      expect(@content.public_content.version == existing_public_version).to be_truthy
    end

    specify 'when you #unpublish there is no PublicContent' do
      expect(@content.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
      expect(@content.unpublish).to be_truthy
      expect(PublicContent.all.count).to eq(0)
    end
  end


  # See the Papertrail gem https://github.com/airblade/paper_trail
  context 'use', :versioning => true do
    specify 'within a `with_versioning` block it will be turned on' do
      expect(PaperTrail).to be_enabled
    end

    context 'some Papertrail methods' do
      before(:each) {
        @c = FactoryGirl.build(:valid_content)
        @c.save!
      }

      specify 'versions' do
        expect(@c.versions.count).to eq(1)
      end

      specify 'another version' do
        @c.text = 'new text'
        expect(@c.save).to be_truthy
        expect(@c.versions.count).to eq(2)
      end

      specify 'live?'  do
        expect(@c.live?).to be_truthy
      end
    end
  end

end
