require 'rails_helper'

describe Namespace, :type => :model do
  let(:namespace) { FactoryBot.build(:namespace) }

  context 'validation' do
    context 'requires' do
      before(:each) {
        namespace.valid?
      }
      specify 'name' do
        expect(namespace.errors.include?(:name)).to be_truthy
      end

      specify 'short_name' do
        expect(namespace.errors.include?(:short_name)).to be_truthy
      end
    end

    context 'uniqueness' do
      before(:each) {
        n1 = FactoryBot.create(:namespace, name: 'Final Frontier', short_name: 'Final')
        @n2 = FactoryBot.build(:valid_namespace, name: 'Final Frontier', short_name: 'Final')
        @n2.valid?
      }
      specify 'name is unique' do
        expect(@n2.errors.include?(:name)).to be_truthy
      end

      specify 'short_name is unique' do
        expect(@n2.errors.include?(:short_name)).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
