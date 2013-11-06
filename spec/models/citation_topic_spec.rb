require 'spec_helper'

describe CitationTopic do
  let(:citationtopic) { CitationTopic.new }

  pending "add some examples to (or delete) #{__FILE__}"

  context 'Beth' do
    context 'validation' do
      before do
        citationtopic.valid?
      end

      context 'required fields' do
        specify 'citation_id' do
          expect(citationtopic.errors.include?(:citation_id)).to be_true
        end

        specify 'topic_id' do
          expect(citationtopic.errors.include?(:topic_id)).to be_true
        end
      end

      context 'no duplicates' do
        # create citation
        # create topic
        # create cite_topic
        # save & reload
        # try to save again - maybe with added pages
      end
    end
  end
end
