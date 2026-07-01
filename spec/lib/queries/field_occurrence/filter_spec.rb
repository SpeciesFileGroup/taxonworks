require 'rails_helper'

describe Queries::FieldOccurrence::Filter, type: :model, group: [:field_occurrence, :filter] do

  context 'sort param' do
    # `no_dwc_occurrence: true` skips the auto-created DwcOccurrence + its
    # polymorphic UUID identifier, which would otherwise pollute MIN(cached)
    # in the identifiers sort test. Matches the valid_specimen factory
    # convention.
    let!(:fo_a) { FactoryBot.create(:valid_field_occurrence, total: 1, no_dwc_occurrence: true) }
    let!(:fo_z) { FactoryBot.create(:valid_field_occurrence, total: 9, no_dwc_occurrence: true) }

    specify 'sort=field_occurrence.total orders ascending by direct column' do
      q = Queries::FieldOccurrence::Filter.new(
        field_occurrence_id: [fo_z.id, fo_a.id], sort: 'field_occurrence.total'
      )
      expect(q.all.map(&:id)).to eq([fo_a.id, fo_z.id])
    end

    specify 'sort=-field_occurrence.id desc' do
      q = Queries::FieldOccurrence::Filter.new(
        field_occurrence_id: [fo_a.id, fo_z.id], sort: '-field_occurrence.id'
      )
      expect(q.all.map(&:id)).to eq([fo_z.id, fo_a.id])
    end

    context 'belongs_to: collecting_event.verbatim_locality' do
      let!(:ce_a) { FactoryBot.create(:valid_collecting_event, verbatim_locality: 'Adirondacks') }
      let!(:ce_z) { FactoryBot.create(:valid_collecting_event, verbatim_locality: 'Zion') }

      specify do
        fo_a.update!(collecting_event: ce_z)
        fo_z.update!(collecting_event: ce_a)
        q = Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'collecting_event.verbatim_locality'
        )
        expect(q.all.map(&:id)).to eq([fo_z.id, fo_a.id])
      end
    end

    context 'polymorphic has_one: dwc_occurrence.scientificName' do
      specify do
        # no_dwc_occurrence was set on the outer let!s, so the DwcOccurrences
        # don't exist yet -- create them here.
        DwcOccurrence.create!(
          dwc_occurrence_object: fo_a, scientificName: 'Zus eus', basisOfRecord: 'HumanObservation'
        )
        DwcOccurrence.create!(
          dwc_occurrence_object: fo_z, scientificName: 'Aus dus', basisOfRecord: 'HumanObservation'
        )
        q = Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'dwc_occurrence.scientificName'
        )
        expect(q.all.map(&:id)).to eq([fo_z.id, fo_a.id])
      end
    end

    context 'taxon_determinations.otu_name (primary determination)' do
      let(:root) { FactoryBot.create(:root_taxon_name) }
      let(:tn_a) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
      let(:tn_z) { Protonym.create!(name: 'Zus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
      let!(:otu_a) { Otu.create!(name: 'aus_otu', taxon_name: tn_a) }
      let!(:otu_z) { Otu.create!(name: 'zus_otu', taxon_name: tn_z) }

      specify 'picks the lowest-position determination as primary' do
        # Factory built one determination per FO at position 1; skip callbacks
        # (which prevent destroy on the last determination) via delete_all so
        # we can define the primary explicitly.
        [fo_a, fo_z].each { |fo| fo.taxon_determinations.delete_all }

        TaxonDetermination.create!(taxon_determination_object: fo_a, otu: otu_z, position: 1)
        TaxonDetermination.create!(taxon_determination_object: fo_a, otu: otu_a, position: 2)
        TaxonDetermination.create!(taxon_determination_object: fo_z, otu: otu_a, position: 1)
        q = Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'taxon_determinations.otu_name'
        )
        # fo_z's primary is aus_otu < fo_a's primary is zus_otu
        expect(q.all.map(&:id)).to eq([fo_z.id, fo_a.id])
      end
    end

    context 'identifiers.cached (aggregated)' do
      let!(:ns) { FactoryBot.create(:valid_namespace) }

      specify 'sorts by the alphabetically first identifier per FO' do
        Identifier::Local::CatalogNumber.create!(
          identifier_object: fo_a, namespace: ns, identifier: '999'
        )
        Identifier::Local::CatalogNumber.create!(
          identifier_object: fo_z, namespace: ns, identifier: '001'
        )
        q = Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'identifiers.cached'
        )
        expect(q.all.map(&:id)).to eq([fo_z.id, fo_a.id])
      end
    end

    specify 'unknown sort key ignored' do
      q = Queries::FieldOccurrence::Filter.new(
        field_occurrence_id: [fo_a.id, fo_z.id], sort: 'no_such_column'
      )
      expect(q.all.map(&:id)).to contain_exactly(fo_a.id, fo_z.id)
    end
  end
end
