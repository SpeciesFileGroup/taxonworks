require 'rails_helper'

describe OtuPageLayout, :type => :model do
  let(:otu_page_layout) {FactoryGirl.build(:otu_page_layout)} 

  context 'validation' do
    context 'required' do
      before(:each) do
        otu_page_layout.valid?
      end

      specify 'name' do
        expect(otu_page_layout.errors.include?(:name)).to be_truthy
      end
    end

 end

  context 'associations' do
    specify 'otu_page_layout_sections' do
      expect(otu_page_layout).to respond_to(:otu_page_layout_sections) 
    end

    specify 'topics' do
      expect(otu_page_layout).to respond_to(:topics) 
    end

  end
end
