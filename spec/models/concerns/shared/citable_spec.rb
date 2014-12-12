require 'rails_helper'

describe 'Citable', :type => :model do
  let(:class_with_citations) { TestCitable.new } 
  context 'associations' do
    specify 'has many citations - includes creating a citation' do
      expect(class_with_citations).to respond_to(:citations) # tests that the method citations exists
      expect(class_with_citations.citations.to_a).to eq([]) # there are no citations yet.

      expect(class_with_citations.citations << FactoryGirl.build(:citation, source: FactoryGirl.create(:valid_source_bibtex))).to be_truthy
      expect(class_with_citations.citations.size).to eq(1)
      expect(class_with_citations.save).to be_truthy
    end
  end

  context 'instance methods' do
    specify 'cited? with no citations' do
      expect(class_with_citations.cited?).to eq(false)
    end

    specify 'cited? with some citations' do
      class_with_citations.citations << Citation.new(source: FactoryGirl.create(:valid_source_bibtex))
      expect(class_with_citations.cited?).to eq(true)
    end

  end
end

class TestCitable < ActiveRecord::Base
  include FakeTable
  include Shared::Citable
end


