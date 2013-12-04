require 'spec_helper'

describe Namespace do
  let(:namespace) { Namespace.new }

  context 'validation' do
    context 'requires' do
      before(:each) {
        namespace.valid?
      }
      specify 'name' do
        expect(namespace.errors.include?(:name)).to be_true
      end 

      specify 'short_name' do
        expect(namespace.errors.include?(:short_name)).to be_true
      end 
    end

    context 'uniqueness' do
      before(:each) {
        n1 = FactoryGirl.create(:valid_namespace)
        @n2 = FactoryGirl.build(:valid_namespace)
        @n2.valid?
      }
      specify 'name is unique' do
        expect(@n2.errors.include?(:name)).to be_true
      end

      specify 'short_name is unique' do
        expect(@n2.errors.include?(:short_name)).to be_true
      end
    end

  end

end
