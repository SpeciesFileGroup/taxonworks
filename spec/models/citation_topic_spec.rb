require 'rails_helper'

describe CitationTopic, :type => :model do
  let(:ct) { CitationTopic.new }
  let(:s) { FactoryGirl.create(:valid_source) }
  let(:oa) { FactoryGirl.create(:valid_otu) }
  let(:ob) { FactoryGirl.create(:valid_otu) }
  let(:ca) { FactoryGirl.create(:valid_citation, {citation_object: oa, source: s}) }
  let(:cb) { FactoryGirl.create(:valid_citation, {citation_object: ob, source: s}) }
  let(:ta) { FactoryGirl.create(:valid_topic) }
  let(:tb) { FactoryGirl.create(:valid_topic) }
  let(:cta) { FactoryGirl.create(:citation_topic, {topic: ta, citation: ca}) }
  let(:ctb) { FactoryGirl.build(:citation_topic, {topic: ta, citation: cb}) }


  context 'citation_topic' do
    context 'validation' do
      before do
        ct.valid?
      end

      context 'required fields' do

        specify 'citation_id' do
          expect(ct.errors.include?(:citation_id)).to be_truthy
        end

        specify 'topic_id' do
          expect(ct.errors.include?(:topic_id)).to be_truthy
        end
      end

      context 'no duplicates' do

        specify 'of topic' do
          expect(cta.valid?).to be_truthy
          # ctb.topic is same as cta.topic
          expect(ctb.valid?).to be_falsey
          expect(ctb.errors.messages[:topic_id][0]).to eq('has already been taken')
          # change the topic to second one
          ctb.topic = tb
          # retest
          expect(ctb.valid?).to be_truthy
        end

        specify 'of citation' do
          expect(cta.valid?).to be_truthy
          # ctb.citation is same as cta.citation
          ctb.citation = ca
          expect(ctb.valid?).to be_falsey
          expect(ctb.errors.messages[:citation_id][0]).to eq('has already been taken')
          # change the topic to second one
          ctb.topic = tb
          # change the citation to second one
          ctb.citation = cb
          # retest
          expect(ctb.valid?).to be_truthy
        end
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
