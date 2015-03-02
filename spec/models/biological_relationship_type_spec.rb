require 'rails_helper'

describe BiologicalRelationshipType, :type => :model do
  let(:biological_relationship_type) { FactoryGirl.build(:biological_relationship_type) }

  context "validation" do 
    context "requires" do
      before do
        biological_relationship_type.valid?
      end

      specify "type" do
        expect(biological_relationship_type.errors.include?(:type)).to be_truthy
      end

      specify "biological_property" do
        expect(biological_relationship_type.errors.include?(:biological_property)).to be_truthy
      end
 
     specify "biological_relationship" do
        expect(biological_relationship_type.errors.include?(:biological_relationship)).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end

