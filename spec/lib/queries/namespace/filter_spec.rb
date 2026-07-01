require 'rails_helper'

describe Queries::Namespace::Filter, type: :model, group: [:filter] do

  context 'sort param' do
    # Note: passing `namespace_id: [...]` to this filter triggers a
    # pre-existing conflict with Queries::Concerns::Identifiers'
    # identifier_namespace_facet (which uses the same name for a different
    # purpose). Tests scope the result externally with `.where(id: ...)`
    # instead.
    let!(:ns_a) {
      FactoryBot.create(:valid_namespace,
        name: 'Alpha_sort museum',
        short_name: 'ALPHA_S',
        institution: 'Alpha_s inst.')
    }
    let!(:ns_z) {
      FactoryBot.create(:valid_namespace,
        name: 'Zeta_sort museum',
        short_name: 'ZETA_S',
        institution: 'Zeta_s inst.')
    }

    def sorted_ids(sort_key)
      Queries::Namespace::Filter.new(sort: sort_key)
        .all.where(id: [ns_a.id, ns_z.id]).pluck(:id)
    end

    specify 'sort=name orders alphabetically' do
      expect(sorted_ids('name')).to eq([ns_a.id, ns_z.id])
    end

    specify 'sort=-name desc' do
      expect(sorted_ids('-name')).to eq([ns_z.id, ns_a.id])
    end

    specify 'sort=shortName uses namespaces.short_name' do
      expect(sorted_ids('shortName')).to eq([ns_a.id, ns_z.id])
    end

    specify 'sort=institution direct column' do
      expect(sorted_ids('institution')).to eq([ns_a.id, ns_z.id])
    end

    specify 'unknown sort key ignored' do
      expect(sorted_ids('no_such_column')).to contain_exactly(ns_a.id, ns_z.id)
    end
  end
end
