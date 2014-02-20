require 'spec_helper'

describe BiologicalProperty do
  let(:biological_property) { FactoryGirl.build(:controlled_vocabulary_term_biological_property) }

  context "validation" do 
    context "requires" do
      before do
        biological_property.valid?
      end

      specify "name" do
        expect(biological_property.errors.include?(:name)).to be_true
      end

      specify "definition" do
        expect(biological_property.errors.include?(:definition)).to be_true
      end
    end
  end
end
