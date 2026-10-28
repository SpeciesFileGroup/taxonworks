require 'rails_helper'

describe Queries::FieldOccurrence::Filter, type: :model, group: [:field_occurrences, :collecting_event, :filter] do

  let(:query) { Queries::FieldOccurrence::Filter.new({}) }

  context 'anatomical_part_query' do
    let!(:field_occurrence) { FactoryBot.create(:valid_field_occurrence) }
    let!(:anatomical_part) { FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence) }

    specify 'matches the origin FieldOccurrence' do
      query.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: anatomical_part.id)
      expect(query.all).to contain_exactly(field_occurrence)
    end

    specify 'ignores a non-AnatomicalPart descendant whose id collides with the anatomical part id' do
      shared_id = 91_000_003
      other_field_occurrence = FactoryBot.create(:valid_field_occurrence, id: shared_id)
      FactoryBot.create(:valid_extract, origin: other_field_occurrence, id: shared_id)

      ap = FactoryBot.create(:valid_anatomical_part, ancestor: field_occurrence, id: shared_id)

      query.anatomical_part_query = ::Queries::AnatomicalPart::Filter.new(anatomical_part_id: ap.id)
      expect(query.all).to contain_exactly(field_occurrence)
    end
  end

  context 'determinations and hierarchical search' do
    let!(:ce) { FactoryBot.create(:valid_collecting_event) }

    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:genus1) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
    let!(:genus2) { Protonym.create!(name: 'Bus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) } # synonym

    let!(:species1) { Protonym.create!(name: 'cus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) }
    let!(:species2) { Protonym.create!(name: 'dus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) } # synonym

    let!(:tn1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
      subject_taxon_name: species2, object_taxon_name: species1) }

    let!(:tn2) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
      subject_taxon_name: genus2, object_taxon_name: genus1) }

    let!(:o1) { Otu.create!(taxon_name: species1) } # valid,    parent genus1
    let!(:o2) { Otu.create!(taxon_name: species2) } # invalid,  parent genus1
    let!(:o3) { Otu.create!(taxon_name: genus1) }   # valid

    # fo1: created with otu o1 (position 1), then o2 added on top (position 1) -> o1 becomes historical
    let!(:fo1) { FieldOccurrence.create!(collecting_event: ce, total: 1, otu: o1) }
    let!(:fo2) { FieldOccurrence.create!(collecting_event: ce, total: 1, otu: o2) }
    let!(:fo3) { FieldOccurrence.create!(collecting_event: ce, total: 1, otu: o3) }

    before do
      FactoryBot.create(:valid_taxon_determination, taxon_determination_object: fo1, otu: o2) # current, fo1 historical: o1
      FactoryBot.create(:valid_taxon_determination, taxon_determination_object: fo2, otu: o1) # current, fo2 historical: o2
    end

    specify 'all field occurrences nested in a TaxonName regardless of status' do
      query.taxon_name_id = genus1.id
      query.validity = true # both valid and invalid
      query.taxon_name_current_determination = true # current and historical
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id, fo2.id, fo3.id)
    end

    specify 'all field occurrences nested in a TaxonName, valid only, any determination' do
      query.taxon_name_id = genus1.id
      # validity = nil (valid only, default)
      query.taxon_name_current_determination = true # current and historical
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id, fo2.id, fo3.id)
    end

    specify 'all field occurrences nested in a TaxonName, invalid only, any determination' do
      query.taxon_name_id = genus1.id
      query.validity = false
      query.taxon_name_current_determination = true # current and historical
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id, fo2.id)
    end

    specify 'all field occurrences nested in a TaxonName, valid and current (default)' do
      query.taxon_name_id = genus1.id
      # validity = nil (valid only, default)
      # taxon_name_current_determination = nil (current only, default)
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo2.id, fo3.id)
    end

    specify 'all field occurrences nested in a TaxonName, invalid only, current (default)' do
      query.taxon_name_id = genus1.id
      query.validity = false
      # taxon_name_current_determination = nil (current only, default)
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id)
    end

    specify 'all field occurrences nested in a TaxonName, invalid only, historical' do
      query.taxon_name_id = genus1.id
      query.validity = false
      query.taxon_name_current_determination = false
      query.descendants = true
      expect(query.all.pluck(:id)).to contain_exactly(fo2.id)
    end

    specify 'all field occurrences for an exact TaxonName match, valid only (default)' do
      query.taxon_name_id = species1.id
      query.descendants = false
      # validity = nil (valid only, default)
      # taxon_name_current_determination = nil (current only, default)
      expect(query.all.pluck(:id)).to contain_exactly(fo2.id)
    end

    specify 'all field occurrences for an exact TaxonName match, invalid only' do
      query.taxon_name_id = species2.id
      query.descendants = false
      query.validity = false
      # taxon_name_current_determination = nil (current only, default)
      expect(query.all.pluck(:id)).to contain_exactly(fo1.id)
    end
  end

  context 'sort param' do
    # `no_dwc_occurrence: true` skips the auto-created DwcOccurrence + its
    # polymorphic UUID identifier, which would otherwise pollute MIN(cached)
    # in the identifiers sort test. Matches the valid_specimen factory
    # convention.
    let!(:fo_a) { FactoryBot.create(:valid_field_occurrence, total: 1, no_dwc_occurrence: true) }
    let!(:fo_z) { FactoryBot.create(:valid_field_occurrence, total: 9, no_dwc_occurrence: true) }

    specify 'sort=field_occurrence.total orders ascending by direct column' do
      q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
        field_occurrence_id: [fo_z.id, fo_a.id], sort: 'field_occurrence.total'
      ).all, field_occurrence_id: [fo_z.id, fo_a.id], sort: 'field_occurrence.total')
      expect(q.ordered.map(&:id)).to eq([fo_a.id, fo_z.id])
    end

    specify 'sort=-field_occurrence.id desc' do
      q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
        field_occurrence_id: [fo_a.id, fo_z.id], sort: '-field_occurrence.id'
      ).all, field_occurrence_id: [fo_a.id, fo_z.id], sort: '-field_occurrence.id')
      expect(q.ordered.map(&:id)).to eq([fo_z.id, fo_a.id])
    end

    specify 'sort=collecting_event.geographic_area_name orders by area name' do
      ga_zulu = FactoryBot.create(:valid_geographic_area, name: 'Zulu')
      ga_alpha = FactoryBot.create(:valid_geographic_area, name: 'Alpha')
      fo_a.collecting_event.update_columns(geographic_area_id: ga_zulu.id)
      fo_z.collecting_event.update_columns(geographic_area_id: ga_alpha.id)
      q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
        field_occurrence_id: [fo_a.id, fo_z.id], sort: 'collecting_event.geographic_area_name'
      ).all, field_occurrence_id: [fo_a.id, fo_z.id], sort: 'collecting_event.geographic_area_name')
      expect(q.ordered.map(&:id)).to eq([fo_z.id, fo_a.id])
    end

    context 'belongs_to: collecting_event.verbatim_locality' do
      let!(:ce_a) { FactoryBot.create(:valid_collecting_event, verbatim_locality: 'Adirondacks') }
      let!(:ce_z) { FactoryBot.create(:valid_collecting_event, verbatim_locality: 'Zion') }

      specify do
        fo_a.update!(collecting_event: ce_z)
        fo_z.update!(collecting_event: ce_a)
        q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'collecting_event.verbatim_locality'
        ).all, field_occurrence_id: [fo_a.id, fo_z.id], sort: 'collecting_event.verbatim_locality')
        expect(q.ordered.map(&:id)).to eq([fo_z.id, fo_a.id])
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
        q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'dwc_occurrence.scientificName'
        ).all, field_occurrence_id: [fo_a.id, fo_z.id], sort: 'dwc_occurrence.scientificName')
        expect(q.ordered.map(&:id)).to eq([fo_z.id, fo_a.id])
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
        q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'taxon_determinations.otu_name'
        ).all, field_occurrence_id: [fo_a.id, fo_z.id], sort: 'taxon_determinations.otu_name')
        # fo_z's primary is aus_otu < fo_a's primary is zus_otu
        expect(q.ordered.map(&:id)).to eq([fo_z.id, fo_a.id])
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
        q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
          field_occurrence_id: [fo_a.id, fo_z.id], sort: 'identifiers.cached'
        ).all, field_occurrence_id: [fo_a.id, fo_z.id], sort: 'identifiers.cached')
        expect(q.ordered.map(&:id)).to eq([fo_z.id, fo_a.id])
      end
    end

    specify 'unknown sort key ignored' do
      q = Queries::Pager.new(Queries::FieldOccurrence::Filter.new(
        field_occurrence_id: [fo_a.id, fo_z.id], sort: 'no_such_column'
      ).all, field_occurrence_id: [fo_a.id, fo_z.id], sort: 'no_such_column')
      expect(q.ordered.map(&:id)).to contain_exactly(fo_a.id, fo_z.id)
    end
  end
end
