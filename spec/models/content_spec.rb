require 'rails_helper'

describe Content, :type => :model do
  let(:content) { Content.new() }
  let(:topic) { FactoryGirl.create(:valid_topic)  }
  let(:otu) { FactoryGirl.create(:valid_otu) }
  let(:not_topic) { FactoryGirl.create(:valid_keyword) } 

  context 'validation' do
    before { content.valid?}

    context 'requires' do
     specify 'topic' do
        expect(content.errors.include?(:topic)).to be_truthy
      end
      specify 'text' do
        expect(content.errors.include?(:text)).to be_truthy
      end
      specify 'text' do
        expect(content.errors.include?(:otu)).to be_truthy
      end
    end

    context 'topic' do
      specify 'must only be a topic' do
        expect {content.topic = not_topic}.to raise_error
      end 
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
    let(:content_to_publish) { FactoryGirl.create(:valid_content) }

    specify 'when you #publish there is PublicContent' do
      expect(content_to_publish.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
    end

    specify 'a new version is not published for identically versioned content' do
      expect(content_to_publish.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
      existing_public_version = content_to_publish.public_content.version
      expect(content_to_publish.version == existing_public_version ).to be_truthy
      expect(content_to_publish.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
      expect(content_to_publish.public_content.version == existing_public_version).to be_truthy
    end

    specify 'when you #unpublish there is no PublicContent' do
      expect(content_to_publish.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
      expect(content_to_publish.unpublish).to be_truthy
      expect(PublicContent.all.count).to eq(0)
    end
  end


  # See the Papertrail gem https://github.com/airblade/paper_trail
  context 'use', :versioning => true do
    specify 'within a `with_versioning` block it will be turned on' do
      expect(PaperTrail).to be_enabled
    end

    context 'some Papertrail methods' do
      let(:c) { FactoryGirl.create(:valid_content) }

      specify 'versions' do
        expect(c.versions.count).to eq(1)
      end

      specify 'another version' do
        c.text = 'new text'
        expect(c.save).to be_truthy
        expect(c.versions.count).to eq(2)
      end

      specify 'live?'  do
        expect(c.live?).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
