require 'rails_helper'

describe Namespace, type: :model do
  let(:namespace) { Namespace.new }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify '#short_name can not differ in case only' do
    FactoryBot.create(:valid_namespace, short_name: 'pws')
    n = Namespace.new(short_name: 'PwS')
    n.valid?
    expect(n.errors.include?(:short_name)).to be_truthy
  end

  context 'validation' do
    context 'requires' do
      before { namespace.valid? }
      
      specify 'name' do
        expect(namespace.errors.include?(:name)).to be_truthy
      end

      specify 'short_name' do
        expect(namespace.errors.include?(:short_name)).to be_truthy
      end
    end

    context 'uniqueness' do
      let!(:n1) { FactoryBot.create(:namespace, name: 'Final Frontier', short_name: 'Final') }
      let!(:n2) { FactoryBot.build(:valid_namespace, name: 'Final Frontier', short_name: 'Final') }
      before { n2.valid? }

      specify 'name is unique' do
        expect(n2.errors.include?(:name)).to be_truthy
      end

      specify 'short_name is unique' do
        expect(n2.errors.include?(:short_name)).to be_truthy
      end
    end
  end

  context 'scopes' do
    let(:n1) { FactoryBot.create(:valid_namespace) }
    let(:n2) { FactoryBot.create(:valid_namespace) }
    let!(:identifier) { Identifier::Local::CatalogNumber.create!(identifier_object: otu, identifier: 123, namespace: n1 ) }
    let!(:old_identifier) { Identifier::Local::CatalogNumber.create!(identifier_object: specimen, identifier: 123, namespace: n2, created_at: 2.years.ago ) }

    specify '#used_on_klass 1' do
      expect(Namespace.used_on_klass('Otu')).to contain_exactly(n1)
    end

    specify '#used_on_klass 2' do
      expect(Namespace.used_on_klass('CollectionObject')).to contain_exactly(n2)
    end

    specify '#used_recently' do
      expect(Namespace.used_recently).to contain_exactly(n1)
    end

    specify '#used_on_klass.used_recently' do
      expect(Namespace.used_on_klass('Otu').used_recently).to contain_exactly(n1)
    end
  end

  context 'updates' do
    before { namespace.update!(name: 'AA', short_name: 'A') }
    let(:i) { Identifier::Local::CatalogNumber.create!(namespace: namespace, identifier_object: FactoryBot.create(:valid_otu), identifier: 0) }

    specify 'cached 1' do
      expect(i.cached).to eq('A 0')
    end

    context 'after' do
      before { namespace.update!(name: 'AA', short_name: 'B', delimiter: '_') }
      specify 'cached 1' do
        expect(i.reload.cached).to eq('B_0')
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
