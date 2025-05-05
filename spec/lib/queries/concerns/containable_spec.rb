require 'rails_helper'

describe 'Queries::Concerns::Containable', type: :model do

  let(:qco) { Queries::CollectionObject::Filter.new({}) }
  let(:qe) { Queries::Extract::Filter.new({}) }

  context 'Concerns::Identifier integration' do

    specify '#identifier_start, #identifier_end 1' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)

      i = FactoryBot.build(:valid_identifier_local, identifier: 123)
      c.identifiers << i

      Specimen.create! # not this

      qco.identifier_start = 123
      expect(qco.all).to contain_exactly(s)
    end

    specify '#identifier_start, #identifier_end 2' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)

      i = FactoryBot.build(:valid_identifier_local, identifier: 123)
      c.identifiers << i

      Specimen.create! # not this

      qco.identifier_start = 122
      qco.identifier_end = 124
      expect(qco.all).to contain_exactly(s)
    end

    specify '#identifier' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)

      i = FactoryBot.build(:valid_identifier_local)
      c.identifiers << i

      Specimen.create! # not this

      qco.identifier = i.identifier
      expect(qco.all).to contain_exactly(s)
    end

    specify '#namespace_id 1' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)

      i = FactoryBot.build(:valid_identifier_local)
      c.identifiers << i

      Specimen.create! # not this

      qco.namespace_id = i.namespace_id
      expect(qco.all).to contain_exactly(s)
    end

    specify '#identifier_type 1' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)

      i = FactoryBot.build(:valid_identifier_local)
      c.identifiers << i

      Specimen.create! # not this

      qco.identifier_type = i.type
      expect(qco.all).to contain_exactly(s)
    end

    specify '#local_identifiers 2' do
      c = FactoryBot.create(:valid_container)
      e = FactoryBot.create(:valid_extract, contained_in: c)  # not this
      n = FactoryBot.create(:valid_extract)

      c.identifiers << FactoryBot.create(:valid_identifier_local)

      qe.local_identifiers = false
      expect(qe.all).to contain_exactly(n)
    end

    specify '#local_identifiers 3' do
      c = FactoryBot.create(:valid_container)
      e = FactoryBot.create(:valid_extract, contained_in: c)  # not this
      n = FactoryBot.create(:valid_extract)

      c.identifiers << FactoryBot.create(:valid_identifier_local)
      n.identifiers << FactoryBot.create(:valid_identifier_local)

      qe.local_identifiers = false
      expect(qe.all).to contain_exactly() # they all have!
    end

    specify '#match_identifiers_facet' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)
      Specimen.create! # not this
      i = FactoryBot.build(:valid_identifier_local)
      c.identifiers << i

      qco.match_identifiers = i.cached
      qco.match_identifiers_type = 'identifier'

      expect(qco.all).to contain_exactly(s)
    end

    specify '#local_identifier 1' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)
      Specimen.create! # not this
      c.identifiers << FactoryBot.create(:valid_identifier_local)

      qco.local_identifiers = true
      expect(qco.all).to contain_exactly(s)
    end

    specify '#local_identifiers 2' do
      c = FactoryBot.create(:valid_container)
      s = Specimen.create!(contained_in: c)  # not this
      n = Specimen.create!
      c.identifiers << FactoryBot.create(:valid_identifier_local)

      qco.local_identifiers = false
      expect(qco.all).to contain_exactly(n)
    end
  end

end

class TestContainable < ApplicationRecord
  include FakeTable
  include Shared::Containable
  include Shared::Identifiers
  include Shared::IsData
end

