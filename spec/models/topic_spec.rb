require 'spec_helper'
describe Topic do
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
  
      specify 'page_layout_sections' do
        expect(topic).to respond_to(:page_layout_sections)
      end 

      specify 'page_layouts' do
        expect(topic).to respond_to(:page_layout_sections)
      end 

    end
  end
end

