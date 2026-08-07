require 'rails_helper'

# Determiner is a *Role*, not a person
describe Determiner, type: :model do
  include ActiveJob::TestHelper

  let(:determiner) {Determiner.new}

  let(:p) { FactoryBot.create(:valid_person) }
  let(:td) { FactoryBot.create(:valid_taxon_determination) }

  specify '#dwc_occurrences' do
    s = Specimen.create!
    td = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, determiners: [p])

    perform_enqueued_jobs
    expect(p.roles.first.dwc_occurrences).to contain_exactly(DwcOccurrence.first)
  end

  specify 'on create, change of person_id (never?) or destroy triggers dwc rebuild' do
    s = Specimen.create!
    expect(s.dwc_occurrence.identifiedBy).to eq(nil)
    td = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, determiners: [p])

    perform_enqueued_jobs
    expect(s.dwc_occurrence.reload.identifiedBy).to eq(p.cached)
  end


  context 'associations' do
    context 'has_many' do
      specify 'taxon_determination' do
        expect(determiner).to respond_to(:taxon_determination)
      end

      specify 'determined_otu' do
        expect(determiner).to respond_to(:otu)
      end
    end
  end
end
