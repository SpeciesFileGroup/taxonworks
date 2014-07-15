require 'spec_helper'

describe TaggedSectionKeyword do

  let(:tagged_section_keyword) {FactoryGirl.build(:tagged_section_keyword) }

  context 'validation' do
    context 'required' do
      before(:each) {
        tagged_section_keyword.valid?
      }
      specify 'out_page_layout_section' do
        expect(tagged_section_keyword.errors.include?(:otu_page_layout_section)).to be_truthy
      end

      specify 'keyword' do
        expect(tagged_section_keyword.errors.include?(:keyword)).to be_truthy
      end
    end
  end

  context 'use' do
    specify 'position is set on save' do
      t = FactoryGirl.create(:valid_tagged_section_keyword)
      expect(t.position).to eq(1)
    end
  end

end
