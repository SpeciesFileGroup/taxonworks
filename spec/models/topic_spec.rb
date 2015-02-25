require 'rails_helper'
describe Topic, :type => :model do
  let(:topic) { FactoryGirl.build(:topic) }

  # validation is handlded in superclass or associated classes

  context "associations" do
    context "has many" do
      specify 'citation_topics' do
        expect(topic).to respond_to(:citation_topics)
      end

      specify 'contents' do
        expect(topic).to respond_to(:contents)
      end

      specify 'otus' do
        expect(topic).to respond_to(:otus)
      end

      specify 'otu_page_layout_sections' do
        expect(topic.otu_page_layout_sections << OtuPageLayoutSection.new).to be_truthy
      end

      specify 'otu_page_layouts' do
        expect(topic.otu_page_layouts << OtuPageLayout.new).to be_truthy
      end

    end
  end
end

