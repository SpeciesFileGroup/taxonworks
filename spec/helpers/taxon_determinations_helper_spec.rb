require 'rails_helper'

describe TaxonDeterminationsHelper, type: :helper do
  context '#taxon_determination_by' do
    let(:taxon_determination) { FactoryBot.create(:valid_taxon_determination) }

    before do
      Determiner.create!(role_object: taxon_determination, person: FactoryBot.create(:valid_person, last_name: 'Aaa'))
      Determiner.create!(role_object: taxon_determination, organization: FactoryBot.create(:valid_organization, name: 'Org'))
    end

    def query_count(&block)
      n = 0
      count = ->(*, payload) { n += 1 unless payload[:name] == 'SCHEMA' || payload[:cached] }
      ActiveSupport::Notifications.subscribed(count, 'sql.active_record', &block)
      n
    end

    specify 'names people, then organizations' do
      expect(helper.taxon_determination_by(TaxonDetermination.find(taxon_determination.id))).to eq('by Aaa and Org')
    end

    specify 'uses preloaded determiner roles without querying' do
      td = TaxonDetermination.includes(determiner_roles: [:person, :organization]).find(taxon_determination.id)
      by = nil
      expect(query_count { by = helper.taxon_determination_by(td) }).to eq(0)
      expect(by).to eq('by Aaa and Org')
    end
  end
end
