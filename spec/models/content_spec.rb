require 'rails_helper'

describe Content, type: :model do
  let(:content) { Content.new() }
  let(:topic) { FactoryBot.create(:valid_topic)  }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:not_topic) {FactoryBot.create(:valid_keyword)}

  context 'validation' do
    before { content.valid?}

    context 'requires' do
      specify 'topic_id' do
        expect(content.errors.include?(:topic_id)).to be_truthy
      end
      specify 'text' do
        expect(content.errors.include?(:text)).to be_truthy
      end
      specify 'otu_id' do
        expect(content.errors.include?(:otu_id)).to be_truthy
      end
    end

    context 'topic' do
      specify 'must only be a topic' do
        expect {content.topic = not_topic}.to raise_error(ActiveRecord::AssociationTypeMismatch)
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
    let(:content_to_publish) { FactoryBot.create(:valid_content) }

    specify 'when you #publish there is PublicContent' do
      expect(content_to_publish.publish).to be_truthy
      expect(PublicContent.all.count).to eq(1)
    end

    xspecify 'a new version is not published for identically versioned content' do
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

    specify '#is_public' do 
      content_to_publish.update!(is_public: true)
      expect(PublicContent.all.count).to eq(1)
    end
  end

  # See the Papertrail gem https://github.com/airblade/paper_trail
  context 'use in specs' do
    specify 'within a `with_versioning` block it will be turned on' do
      with_versioning do
        expect(PaperTrail).to be_enabled
      end
    end

    context 'some Papertrail methods' do
      let(:c) { FactoryBot.create(:valid_content) }

      specify 'versions not created on create' do
        expect(c.versions.count).to eq(0)
      end

      specify 'another version' do
        with_versioning do
          c.text = 'new text'
          expect(c.save).to be_truthy
          expect(c.versions.count).to eq(1)
        end
      end

      specify 'live?'  do
        expect(c.paper_trail.live?).to be_truthy
      end
    end
  end

  specify '#text is not trimmed' do
    s = " asdf sd  \n  asdfd \r\n" 
    content.text = s
    content.valid?
    expect(content.text).to eq(s)
  end



  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
