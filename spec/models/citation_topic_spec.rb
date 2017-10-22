require 'rails_helper'

describe CitationTopic, type: :model do

  let(:citation_topic) { CitationTopic.new }

  let(:otu) { FactoryGirl.create(:valid_otu) }
  let(:source) { FactoryGirl.create(:valid_source) }
  let(:citation) { Citation.create!(citation_object: otu, source: source) }

  let(:topic) { FactoryGirl.create(:valid_topic) }

  let(:oa) { FactoryGirl.create(:valid_otu) }
  let(:ob) { FactoryGirl.create(:valid_otu) }

  let(:cb) { FactoryGirl.create(:valid_citation, {citation_object: ob, source: source}) }

  context 'validation' do
    before do
      citation_topic.valid?
    end

    specify '#topic_id is a database constraint' do
      citation_topic.citation = citation
      expect{citation_topic.save}.to raise_error(ActiveRecord::StatementInvalid,  /null value in column "topic_id"/) 
    end

    specify '#citation_id is a database constraint' do
      citation_topic.topic = topic 
      expect{citation_topic.save}.to raise_error(ActiveRecord::StatementInvalid, /null value in column "citation_id"/) 
    end

    context 'no duplicates' do

      let!(:cta) { CitationTopic.create!(topic: topic, citation: citation) }
      let(:ctb) { CitationTopic.new(topic: topic, citation: citation) }

      before {
        ctb.valid?
      }

      specify 'of topic' do
        expect(ctb.errors.messages[:topic_id]).to include('has already been taken')
      end

    end
  end

  context 'nested_attributes_for :topics' do
    let(:o) { FactoryGirl.create(:valid_otu) }

    specify 'citation, citation topic, and topic can all be created together' do
      o.citations << Citation.new(source: source, citation_topics_attributes: [ { topic_attributes: {name: 'ABC', definition: 'Easy as 123, but with more characters' }  } ] ) 

      expect(Topic.all.count).to eq(1)
      expect(o.topics.first.name).to eq('ABC')
    end

  end


  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
